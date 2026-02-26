import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Token z healthapi.garmin.com/tools – najpierw apis.garmin.com (często token jest ważny tam).
const GARMIN_ACTIVITIES_URL = "https://apis.garmin.com/wellness-api/rest/activities";
const GARMIN_ACTIVITIES_URL_ALT = "https://healthapi.garmin.com/wellness-api/rest/activities";
const MAX_RANGE_SECONDS = 86400;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("authorization") ?? req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Brak autoryzacji" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseAnonKey);
    // getClaims() działa z nowymi JWT Signing Keys (asymmetric); getUser(jwt) często 401 po migracji.
    let authOk = false;
    if (typeof supabase.auth.getClaims === "function") {
      const { data: claimsData, error: claimsError } = await supabase.auth.getClaims(jwt);
      authOk = !claimsError && !!claimsData?.claims?.sub;
      if (!authOk) console.error("getClaims failed:", claimsError?.message ?? "no claims");
    }
    if (!authOk && typeof supabase.auth.getUser === "function") {
      const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
      authOk = !userError && !!userData?.user;
    }
    if (!authOk) {
      return new Response(
        JSON.stringify({ error: "Invalid JWT" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let body: { access_token: string; upload_start_seconds?: number; upload_end_seconds?: number; debug?: boolean } | null = null;
    try {
      body = (await req.json()) as { access_token: string; upload_start_seconds?: number; upload_end_seconds?: number; debug?: boolean };
    } catch {
      return new Response(
        JSON.stringify({ error: "Nieprawidłowy JSON (wymagane: access_token)" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const accessToken = body?.access_token?.trim();
    if (!accessToken) {
      return new Response(
        JSON.stringify({ error: "Brak access_token" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const now = Math.floor(Date.now() / 1000);
    /** Health API retention: dane starsze niż 7 dni nie są zwracane (policy w Data Viewer). */
    const maxRangeSeconds = 7 * 86400;
    let start = body.upload_start_seconds ?? now - maxRangeSeconds;
    let end = body.upload_end_seconds ?? now;
    if (end - start > maxRangeSeconds) start = end - maxRangeSeconds;

    const pullToken = Deno.env.get("GARMIN_PULL_TOKEN")?.trim();
    if (!pullToken) {
      console.error("GARMIN_PULL_TOKEN is not set in Supabase secrets - set it and redeploy function");
      return new Response(
        JSON.stringify({
          error: "GARMIN_PULL_TOKEN nie ustawiony. Ustaw sekret w Supabase: supabase secrets set GARMIN_PULL_TOKEN='CPT_...'",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }
    const consumerKey = Deno.env.get("GARMIN_CLIENT_ID")?.trim();
    console.log("GARMIN_PULL_TOKEN is set, calling Garmin API", consumerKey ? "(consumer_key w zapytaniu)" : "(brak GARMIN_CLIENT_ID w sekretach)");
    const wantDebug = body?.debug === true;
    const seenIds = new Set<string>();
    const allActivities: Record<string, unknown>[] = [];
    let firstResponseSnippet = "";

    const headers: Record<string, string> = {
      Authorization: `Bearer ${accessToken}`,
      Accept: "application/json",
    };
    if (pullToken) headers["Pull-Token"] = pullToken;

    while (start < end) {
      const chunkEnd = Math.min(start + MAX_RANGE_SECONDS, end);
      let query = `uploadStartTimeInSeconds=${start}&uploadEndTimeInSeconds=${chunkEnd}&token=${encodeURIComponent(pullToken)}`;
      if (consumerKey) query += `&consumer_key=${encodeURIComponent(consumerKey)}`;
      let url = `${GARMIN_ACTIVITIES_URL}?${query}`;
      let garminRes = await fetch(url, { method: "GET", headers });
      let text = await garminRes.text();
      if (wantDebug && firstResponseSnippet === "") firstResponseSnippet = text || "(pusta odpowiedź)";
      if (!garminRes.ok && garminRes.status >= 400) {
        url = `${GARMIN_ACTIVITIES_URL_ALT}?${query}`;
        garminRes = await fetch(url, { method: "GET", headers });
        text = await garminRes.text();
      }
      if (!garminRes.ok) {
        console.error("Garmin API error:", garminRes.status, (text || "").substring(0, 600));
        return new Response(
          JSON.stringify({ error: "Błąd Garmin API", detail: text }),
          { status: garminRes.status >= 400 && garminRes.status < 600 ? garminRes.status : 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      let items: Record<string, unknown>[] = [];
      try {
        const parsed = JSON.parse(text);
        if (Array.isArray(parsed)) {
          items = parsed;
        } else if (parsed && typeof parsed === "object") {
          const arr =
            parsed.activities ??
            parsed.activityList ??
            parsed.payload?.activities ??
            parsed.data ??
            parsed.summary ??
            parsed.summaries ??
            parsed.items;
          if (Array.isArray(arr)) items = arr;
          else {
            for (const v of Object.values(parsed)) {
              if (Array.isArray(v) && v.length > 0 && typeof v[0] === "object" && v[0] !== null) {
                items = v as Record<string, unknown>[];
                break;
              }
            }
          }
        }
      } catch {
        // ignore parse error
      }

      for (const a of items) {
        const id = String(
          a?.activityId ?? a?.activity_id ?? a?.uuid ?? a?.id ?? a?.summaryId ?? a?.uploadId ?? ""
        );
        if (id && !seenIds.has(id)) {
          seenIds.add(id);
          allActivities.push(a);
        }
      }

      start = chunkEnd;
    }

    const emptyHint =
      "Garmin Health API zwraca dane tylko z ostatnich 7 dni. W środowisku Evaluation (testowym) API może w ogóle nie udostępniać danych Pull – wtedy synchronizacja będzie pusta mimo aktywności na koncie. Sprawdź Data Viewer (healthapi.garmin.com/tools/dataViewer) lub upewnij się, że GARMIN_PULL_TOKEN jest ustawiony i ważny w Supabase.";

    const payload: Record<string, unknown> =
      allActivities.length === 0
        ? {
            activities: allActivities,
            empty_hint: emptyHint,
            ...(wantDebug && { _debug: { firstResponseSnippet: (firstResponseSnippet || "(pusta odpowiedź)").substring(0, 800) } }),
          }
        : { activities: allActivities };

    return new Response(JSON.stringify(payload), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(
      JSON.stringify({ error: "Błąd serwera", detail: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

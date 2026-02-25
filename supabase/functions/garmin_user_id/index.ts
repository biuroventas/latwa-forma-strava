import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const GARMIN_USER_ID_URL = "https://apis.garmin.com/wellness-api/rest/user/id";

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
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: `Bearer ${jwt}` } },
    });

    const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
    if (userError || !userData?.user) {
      return new Response(
        JSON.stringify({ error: "Invalid JWT" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const userId = userData.user.id;
    const { data: row } = await supabase
      .from("garmin_integrations")
      .select("access_token")
      .eq("user_id", userId)
      .maybeSingle();

    const accessToken = row?.access_token?.trim();
    if (!accessToken) {
      return new Response(
        JSON.stringify({ error: "Brak połączenia z Garmin. Połącz konto w Integracjach." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const idRes = await fetch(GARMIN_USER_ID_URL, {
      method: "GET",
      headers: { Authorization: `Bearer ${accessToken}`, Accept: "application/json" },
    });

    if (!idRes.ok) {
      const text = await idRes.text();
      return new Response(
        JSON.stringify({ error: "Błąd Garmin API", detail: text }),
        { status: idRes.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const idJson = (await idRes.json()) as { userId?: string };
    const garminUserId = idJson?.userId;
    if (typeof garminUserId !== "string") {
      return new Response(
        JSON.stringify({ error: "Garmin nie zwrócił User ID" }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(JSON.stringify({ userId: garminUserId }), {
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

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const GARMIN_TOKEN_URL = "https://diauth.garmin.com/di-oauth2-service/oauth/token";

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
    const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
    if (userError || !userData?.user) {
      return new Response(
        JSON.stringify({ code: 401, message: "Invalid JWT", error: userError?.message ?? "getUser failed" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const clientId = Deno.env.get("GARMIN_CLIENT_ID");
    const clientSecret = Deno.env.get("GARMIN_CLIENT_SECRET");
    const redirectUri = Deno.env.get("GARMIN_REDIRECT_URI") ?? "https://latwaforma.pl/garmin-callback.html";

    if (!clientId || !clientSecret) {
      return new Response(
        JSON.stringify({ error: "Brak konfiguracji Garmin (GARMIN_CLIENT_ID / GARMIN_CLIENT_SECRET)" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let body: { code?: string; code_verifier?: string };
    try {
      body = (await req.json()) as { code?: string; code_verifier?: string };
    } catch {
      return new Response(
        JSON.stringify({ error: "Nieprawidłowy JSON (wymagane: code, code_verifier)" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { code, code_verifier } = body;
    if (!code?.trim() || !code_verifier?.trim()) {
      return new Response(
        JSON.stringify({ error: "Brak code lub code_verifier" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const formBody = new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      code: code.trim(),
      grant_type: "authorization_code",
      redirect_uri: redirectUri,
      code_verifier: code_verifier.trim(),
    }).toString();

    const tokenRes = await fetch(GARMIN_TOKEN_URL, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: formBody,
    });

    const tokenText = await tokenRes.text();
    if (!tokenRes.ok) {
      return new Response(
        JSON.stringify({ error: "Błąd Garmin", detail: tokenText }),
        { status: tokenRes.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let tokenJson: { access_token?: string; refresh_token?: string; expires_in?: number };
    try {
      tokenJson = JSON.parse(tokenText) as { access_token?: string; refresh_token?: string; expires_in?: number };
    } catch {
      return new Response(
        JSON.stringify({ error: "Nieprawidłowa odpowiedź Garmin" }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({
        access_token: tokenJson.access_token,
        refresh_token: tokenJson.refresh_token ?? null,
        expires_in: tokenJson.expires_in ?? 3600,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: "Błąd serwera", detail: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

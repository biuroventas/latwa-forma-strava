import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const defaultRedirectUrl = "https://latwaforma.pl/";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Brak autoryzacji" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!jwt) {
      return new Response(
        JSON.stringify({ error: "Brak tokenu" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const redirectUrl = Deno.env.get("INVITE_REDIRECT_URL") ?? defaultRedirectUrl;

    const supabaseUser = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: userError } = await supabaseUser.auth.getUser(jwt);

    if (userError || !user || user.isAnonymous) {
      return new Response(
        JSON.stringify({ error: "Musisz być zalogowany, aby zapraszać" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const body = await req.json().catch(() => ({}));
    const email = typeof body?.email === "string" ? body.email.trim() : "";
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return new Response(
        JSON.stringify({ error: "Podaj prawidłowy adres e-mail" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false },
    });

    let { data: inviteData, error: inviteError } = await supabaseAdmin.auth.admin.inviteUserByEmail(
      email,
      { redirectTo: redirectUrl }
    );

    let wasAlreadyInvited = false;
    if (inviteError) {
      const msg = inviteError.message.toLowerCase();
      if (msg.includes("already been registered") || msg.includes("already exists")) {
        return new Response(
          JSON.stringify({ error: "Użytkownik z tym adresem e-mail ma już konto" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      if (msg.includes("already been invited") || msg.includes("already invited") || msg.includes("invitation has already been sent") || msg.includes("invitation")) {
        wasAlreadyInvited = true;
        const retry = await supabaseAdmin.auth.admin.inviteUserByEmail(
          email,
          { redirectTo: redirectUrl }
        );
        inviteError = retry.error;
        inviteData = retry.data;
      }
      if (inviteError) {
        if (msg.includes("over email rate limit")) {
          return new Response(
            JSON.stringify({ error: "Zbyt wiele zaproszeń. Poczekaj chwilę i spróbuj ponownie." }),
            { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }
        if (wasAlreadyInvited) {
          return new Response(
            JSON.stringify({
              success: true,
              message: "Na ten adres e-mail wysłano już wcześniej zaproszenie. Wysłaliśmy je ponownie – sprawdź skrzynkę (w tym spam).",
            }),
            { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }
        // Nie przekazuj surowego błędu (może zawierać "email") – zwróć ogólny komunikat
        return new Response(
          JSON.stringify({ error: "Nie udało się wysłać zaproszenia. Sprawdź adres e-mail lub spróbuj później." }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: wasAlreadyInvited
          ? "Na ten adres e-mail wysłano już wcześniej zaproszenie. Wysłaliśmy je ponownie – sprawdź skrzynkę (w tym spam)."
          : `Zaproszenie wysłano na ${email}`,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error(err);
    return new Response(
      JSON.stringify({ error: "Błąd serwera" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

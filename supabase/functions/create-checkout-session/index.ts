import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Nagłówki w fetch/Deno są zwykle w lowercase.
    const authHeader = req.headers.get("authorization") ?? req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Brak autoryzacji" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY");
    const priceMonthly = Deno.env.get("STRIPE_PREMIUM_PRICE_MONTHLY");
    const priceYearly = Deno.env.get("STRIPE_PREMIUM_PRICE_YEARLY");
    const priceYearlyOneTime = Deno.env.get("STRIPE_PREMIUM_PRICE_YEARLY_ONE_TIME"); // płatność jednorazowa za rok – BLIK
    const priceFallback = Deno.env.get("STRIPE_PREMIUM_PRICE_ID"); // stara konfiguracja – jeden price
    // Domyślnie app.latwaforma.pl (web). Sekrety STRIPE_SUCCESS_URL / STRIPE_CANCEL_URL nadpisują.
    const successUrl = Deno.env.get("STRIPE_SUCCESS_URL") ?? "https://app.latwaforma.pl/#/premium-success";
    const cancelUrl = Deno.env.get("STRIPE_CANCEL_URL") ?? "https://app.latwaforma.pl/#/premium-cancel";

    let plan: "monthly" | "yearly" | "yearly_once" = "monthly";
    try {
      const body = await req.json() as { plan?: string } | null;
      if (body?.plan === "yearly_once") plan = "yearly_once";
      else if (body?.plan === "yearly") plan = "yearly";
    } catch {
      // brak body lub nie JSON – domyślnie monthly
    }

    const isOneTimeYear = plan === "yearly_once";
    const stripePriceId = isOneTimeYear
      ? priceYearlyOneTime
      : plan === "yearly"
        ? (priceYearly || priceFallback)
        : (priceMonthly || priceFallback);

    if (!stripeSecretKey || !stripePriceId) {
      const msg = isOneTimeYear
        ? "Brak konfiguracji Stripe. Dla płatności jednorazowej (BLIK) ustaw STRIPE_PREMIUM_PRICE_YEARLY_ONE_TIME (cena jednorazowa w PLN w Stripe)."
        : "Brak konfiguracji Stripe. Ustaw STRIPE_SECRET_KEY oraz STRIPE_PREMIUM_PRICE_MONTHLY i STRIPE_PREMIUM_PRICE_YEARLY (lub STRIPE_PREMIUM_PRICE_ID).";
      return new Response(
        JSON.stringify({ error: msg }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!jwt) {
      return new Response(
        JSON.stringify({ error: "Brak tokenu" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey);
    const { data, error: userError } = await supabase.auth.getUser(jwt);
    const user = data?.user;
    if (userError || !user) {
      return new Response(
        JSON.stringify({
          error: "Nieprawidłowa sesja",
          detail: userError?.message ?? "getUser failed",
        }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const stripe = new Stripe(stripeSecretKey);

    if (isOneTimeYear) {
      // Płatność jednorazowa za rok – karta, BLIK, PayPal (BLIK w Stripe tylko przy mode: "payment").
      const session = await stripe.checkout.sessions.create({
        mode: "payment",
        line_items: [{ price: stripePriceId, quantity: 1 }],
        payment_method_types: ["card", "blik", "paypal"],
        success_url: successUrl,
        cancel_url: cancelUrl,
        client_reference_id: user.id,
        customer_email: user.email ?? undefined,
        locale: "pl",
      });
      return new Response(
        JSON.stringify({ url: session.url }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      line_items: [{ price: stripePriceId, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,
      client_reference_id: user.id,
      customer_email: user.email ?? undefined,
      locale: "pl",
    });

    return new Response(
      JSON.stringify({ url: session.url }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("create-checkout-session error:", err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : "Błąd serwera" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

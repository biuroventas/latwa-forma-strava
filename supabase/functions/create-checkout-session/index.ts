import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

/// Aktywny kod w Stripe wskazuje kupony pierwszej płatności (metadata month_coupon / year_coupon).
async function _couponForPromo(
  stripe: Stripe,
  code: string,
  plan: "monthly" | "yearly" | "yearly_once",
): Promise<string | null> {
  const candidates = [...new Set([code, code.toUpperCase()])];
  for (const candidate of candidates) {
    const listed = await stripe.promotionCodes.list({ code: candidate, active: true, limit: 1 });
    const promo = listed.data[0];
    if (!promo) continue;
    const monthCoupon = promo.metadata?.month_coupon?.trim();
    const yearCoupon = promo.metadata?.year_coupon?.trim();
    if (plan === "yearly") return yearCoupon || null;
    if (plan === "monthly") return monthCoupon || null;
  }
  return null;
}

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
    const priceYearlyOneTime = Deno.env.get("STRIPE_PREMIUM_PRICE_YEARLY_ONE_TIME"); // płatność jednorazowa za rok – tylko BLIK
    const priceFallback = Deno.env.get("STRIPE_PREMIUM_PRICE_ID"); // stara konfiguracja – jeden price
    // Domyślnie latwaforma.pl (web). Sekrety STRIPE_SUCCESS_URL / STRIPE_CANCEL_URL nadpisują.
    const successUrl = Deno.env.get("STRIPE_SUCCESS_URL") ?? "https://latwaforma.pl/#/premium-success";
    const cancelUrl = Deno.env.get("STRIPE_CANCEL_URL") ?? "https://latwaforma.pl/#/premium-cancel";

    let plan: "monthly" | "yearly" | "yearly_once" = "monthly";
    let promoCode = "";
    try {
      const body = await req.json() as { plan?: string; promoCode?: string } | null;
      if (body?.plan === "yearly_once") plan = "yearly_once";
      else if (body?.plan === "yearly") plan = "yearly";
      promoCode = (body?.promoCode ?? "").trim();
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

    if (promoCode && isOneTimeYear) {
      return new Response(
        JSON.stringify({ error: "Ten kod nie działa przy płatności jednorazowej." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let discounts: Stripe.Checkout.SessionCreateParams.Discount[] | undefined;
    if (promoCode) {
      const couponId = await _couponForPromo(stripe, promoCode, plan);
      if (!couponId) {
        return new Response(
          JSON.stringify({ error: "Nieprawidłowy kod." }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      discounts = [{ coupon: couponId }];
    }

    if (isOneTimeYear) {
      // Płatność jednorazowa za rok – tylko BLIK (Stripe BLIK wymaga mode: "payment").
      const session = await stripe.checkout.sessions.create({
        mode: "payment",
        line_items: [{ price: stripePriceId, quantity: 1 }],
        payment_method_types: ["blik"],
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
      // Tylko karta – Apple Pay / Google Pay wchodzą razem z card. Bez Klarny i BLIK.
      payment_method_types: ["card"],
      ...(discounts ? { discounts } : {}),
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

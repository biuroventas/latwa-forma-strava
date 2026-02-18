import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, stripe-signature",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405, headers: corsHeaders });
  }

  const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY");
  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  if (!stripeSecretKey || !webhookSecret || !supabaseServiceKey) {
    console.error("Missing STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET or SUPABASE_SERVICE_ROLE_KEY");
    return new Response("Server configuration error", { status: 500, headers: corsHeaders });
  }

  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    return new Response("No stripe-signature", { status: 400, headers: corsHeaders });
  }

  let body: string;
  try {
    body = await req.text();
  } catch {
    return new Response("Invalid body", { status: 400, headers: corsHeaders });
  }

  let event: Stripe.Event;
  try {
    event = await new Stripe(stripeSecretKey).webhooks.constructEventAsync(
      body,
      signature,
      webhookSecret
    );
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    return new Response("Invalid signature", { status: 400, headers: corsHeaders });
  }

  if (event.type !== "checkout.session.completed") {
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const session = event.data.object as Stripe.Checkout.Session;
  const userId = session.client_reference_id as string | null;
  console.log("checkout.session.completed", { userId, mode: session.mode, subscription: session.subscription });
  if (!userId) {
    console.error("checkout.session.completed without client_reference_id – sprawdź, czy create-checkout-session przekazuje client_reference_id: user.id");
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  let expiresAt: string | null = null;
  if (session.mode === "payment") {
    // Płatność jednorazowa (np. rok z BLIK) – Premium na 1 rok od dziś.
    const oneYearFromNow = new Date();
    oneYearFromNow.setFullYear(oneYearFromNow.getFullYear() + 1);
    expiresAt = oneYearFromNow.toISOString();
  } else if (session.subscription && typeof session.subscription === "string") {
    try {
      const stripe = new Stripe(stripeSecretKey);
      const subscription = await stripe.subscriptions.retrieve(session.subscription);
      if (subscription.current_period_end) {
        expiresAt = new Date(subscription.current_period_end * 1000).toISOString();
      }
    } catch (e) {
      console.error("Failed to fetch subscription:", e);
    }
  }

  const stripeCustomerId =
    typeof session.customer === "string" ? session.customer : session.customer?.id ?? null;

  const supabase = createClient(supabaseUrl, supabaseServiceKey, { auth: { persistSession: false } });

  const { data, error } = await supabase
    .from("profiles")
    .update({
      subscription_tier: "premium",
      subscription_expires_at: expiresAt,
      ...(stripeCustomerId && { stripe_customer_id: stripeCustomerId }),
      updated_at: new Date().toISOString(),
    })
    .eq("user_id", userId)
    .select("user_id");

  if (error) {
    console.error("Failed to update profile:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
  if (!data || data.length === 0) {
    console.error("Profile not updated – brak wiersza w profiles dla user_id:", userId);
  } else {
    console.log("Profile updated for user_id:", userId, "expiresAt:", expiresAt);
  }

  return new Response(JSON.stringify({ received: true }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});

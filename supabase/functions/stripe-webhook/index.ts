import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, stripe-signature",
};

function stripeClient(secret: string) {
  return new Stripe(secret);
}

function periodEndIso(subscription: Stripe.Subscription): string | null {
  const itemEnd = subscription.items?.data?.[0]
    ? (subscription.items.data[0] as { current_period_end?: number }).current_period_end
    : undefined;
  const end = subscription.current_period_end ?? itemEnd;
  if (!end) return null;
  return new Date(end * 1000).toISOString();
}

function customerIdFrom(
  customer: string | Stripe.Customer | Stripe.DeletedCustomer | null | undefined,
): string | null {
  if (!customer) return null;
  return typeof customer === "string" ? customer : customer.id ?? null;
}

function subscriptionIdFromInvoice(invoice: Stripe.Invoice): string | null {
  const direct = invoice.subscription;
  if (typeof direct === "string" && direct) return direct;
  if (direct && typeof direct === "object" && "id" in direct) {
    return (direct as { id: string }).id ?? null;
  }
  const nested = (invoice as {
    parent?: { subscription_details?: { subscription?: string | { id?: string } } };
  }).parent?.subscription_details?.subscription;
  if (typeof nested === "string" && nested) return nested;
  if (nested && typeof nested === "object" && nested.id) return nested.id;
  return null;
}

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

  const stripe = stripeClient(stripeSecretKey);
  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(body, signature, webhookSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    return new Response("Invalid signature", { status: 400, headers: corsHeaders });
  }

  const supabase = createClient(supabaseUrl, supabaseServiceKey, { auth: { persistSession: false } });

  try {
    if (event.type === "checkout.session.completed" || event.type === "checkout.session.async_payment_succeeded") {
      await handleCheckoutSession(event.data.object as Stripe.Checkout.Session, stripe, supabase);
    } else if (event.type === "invoice.paid") {
      await handleInvoicePaid(event.data.object as Stripe.Invoice, stripe, supabase);
    } else if (event.type === "customer.subscription.deleted") {
      await handleSubscriptionDeleted(event.data.object as Stripe.Subscription, supabase);
    } else {
      console.log("stripe-webhook ignored", event.type);
    }
  } catch (err) {
    console.error("stripe-webhook handler failed:", event.type, err);
    return new Response(JSON.stringify({ error: "Handler failed" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify({ received: true }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});

async function handleCheckoutSession(
  session: Stripe.Checkout.Session,
  stripe: Stripe,
  supabase: ReturnType<typeof createClient>,
) {
  const userId = session.client_reference_id as string | null;
  console.log("checkout session", {
    type: session.mode,
    payment_status: session.payment_status,
    userId,
    subscription: session.subscription,
  });

  if (!userId) {
    console.error("checkout session without client_reference_id");
    return;
  }

  // BLIK (i inne przekierowania) kończą Checkout zanim bank potwierdzi wpłatę.
  if (session.payment_status !== "paid") {
    console.log("checkout not paid yet – czekam na async_payment_succeeded", session.payment_status);
    return;
  }

  let expiresAt: string | null = null;
  if (session.mode === "payment") {
    const oneYearFromNow = new Date();
    oneYearFromNow.setFullYear(oneYearFromNow.getFullYear() + 1);
    expiresAt = oneYearFromNow.toISOString();
  } else if (session.subscription && typeof session.subscription === "string") {
    try {
      const subscription = await stripe.subscriptions.retrieve(session.subscription);
      expiresAt = periodEndIso(subscription);
    } catch (e) {
      console.error("Failed to fetch subscription:", e);
    }
  }

  const stripeCustomerId = customerIdFrom(session.customer);
  await updateProfile(supabase, { userId, stripeCustomerId, tier: "premium", expiresAt });
}

async function handleInvoicePaid(
  invoice: Stripe.Invoice,
  stripe: Stripe,
  supabase: ReturnType<typeof createClient>,
) {
  const subId = subscriptionIdFromInvoice(invoice);
  // Faktura jednorazowa (BLIK) nie ma subskrypcji – Premium nadaje checkout, nie ten event.
  if (!subId) {
    console.log("invoice.paid without subscription – skip");
    return;
  }

  const customerId = customerIdFrom(invoice.customer);
  if (!customerId) {
    console.error("invoice.paid without customer");
    return;
  }

  let expiresAt: string | null = null;
  try {
    const subscription = await stripe.subscriptions.retrieve(subId);
    expiresAt = periodEndIso(subscription);
  } catch (e) {
    console.error("Failed to fetch subscription for invoice.paid:", e);
  }

  await updateProfile(supabase, {
    stripeCustomerId: customerId,
    tier: "premium",
    expiresAt,
  });
}

async function handleSubscriptionDeleted(
  subscription: Stripe.Subscription,
  supabase: ReturnType<typeof createClient>,
) {
  const customerId = customerIdFrom(subscription.customer);
  if (!customerId) {
    console.error("subscription.deleted without customer");
    return;
  }
  await updateProfile(supabase, {
    stripeCustomerId: customerId,
    tier: "free",
    expiresAt: null,
  });
}

async function updateProfile(
  supabase: ReturnType<typeof createClient>,
  opts: {
    userId?: string | null;
    stripeCustomerId?: string | null;
    tier: "premium" | "free";
    expiresAt: string | null;
  },
) {
  const payload: Record<string, unknown> = {
    subscription_tier: opts.tier,
    subscription_expires_at: opts.expiresAt,
    updated_at: new Date().toISOString(),
  };
  if (opts.stripeCustomerId) payload.stripe_customer_id = opts.stripeCustomerId;

  let query = supabase.from("profiles").update(payload);
  if (opts.userId) query = query.eq("user_id", opts.userId);
  else if (opts.stripeCustomerId) query = query.eq("stripe_customer_id", opts.stripeCustomerId);
  else {
    console.error("updateProfile without userId or stripeCustomerId");
    return;
  }

  const { data, error } = await query.select("user_id");
  if (error) {
    console.error("Failed to update profile:", error);
    throw error;
  }
  if (!data || data.length === 0) {
    console.error("Profile not updated", { userId: opts.userId, stripeCustomerId: opts.stripeCustomerId });
  } else {
    console.log("Profile updated", { userId: data[0].user_id, tier: opts.tier, expiresAt: opts.expiresAt });
  }
}

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

/** Eventy, które oznaczają aktywne Premium. */
const PREMIUM_ACTIVE_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "NON_RENEWING_PURCHASE",
  "PRODUCT_CHANGE",
]);

/** Eventy, które powinny zdjąć Premium (po okresie / natychmiast). */
const PREMIUM_INACTIVE_EVENTS = new Set([
  "EXPIRATION",
  "CANCELLATION", // często jeszcze aktywne do expiration_at – poniżej sprawdzamy expiration
]);

/** W sandboxie Apple miesiąc ≈ 5 min, rok ≈ 1 h. Do UI zapisujemy okres kalendarzowy. */
function displayExpiryIso(
  productId: string,
  expirationMs: number | null,
  purchasedAtMs: number | null,
  now: number,
): string | null {
  const twoDays = 2 * 24 * 60 * 60 * 1000;
  if (expirationMs != null && expirationMs > now + twoDays) {
    return new Date(expirationMs).toISOString();
  }
  const startMs = purchasedAtMs && purchasedAtMs > 0 ? purchasedAtMs : now;
  const start = new Date(startMs);
  const id = productId.toLowerCase();
  if (id.includes("yearly") || id.includes("annual")) {
    start.setFullYear(start.getFullYear() + 1);
    return start.toISOString();
  }
  if (id.includes("monthly") || id === "premium_monthly") {
    start.setMonth(start.getMonth() + 1);
    return start.toISOString();
  }
  if (expirationMs != null && expirationMs > now) {
    return new Date(expirationMs).toISOString();
  }
  return null;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405, headers: corsHeaders });
  }

  const authSecret = Deno.env.get("REVENUECAT_WEBHOOK_AUTH") ?? "";
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  if (!supabaseServiceKey) {
    console.error("Missing SUPABASE_SERVICE_ROLE_KEY");
    return new Response("Server configuration error", { status: 500, headers: corsHeaders });
  }

  if (authSecret) {
    const header = req.headers.get("Authorization") ?? "";
    const token = header.startsWith("Bearer ") ? header.slice(7) : header;
    if (token !== authSecret) {
      return new Response("Unauthorized", { status: 401, headers: corsHeaders });
    }
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return new Response("Invalid JSON", { status: 400, headers: corsHeaders });
  }

  const event = (body.event ?? body) as Record<string, unknown>;
  const type = String(event.type ?? body.type ?? "");
  const appUserId = String(
    event.app_user_id ?? event.appUserId ?? body.app_user_id ?? "",
  ).trim();

  console.log("revenuecat-webhook", { type, appUserId });

  if (!appUserId || appUserId.startsWith("$RCAnonymousID")) {
    // Anonimowy RC – pomijamy (Premium wymaga zalogowanego uid = Supabase).
    return new Response(JSON.stringify({ received: true, skipped: "no_app_user_id" }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const entitlementIds = (event.entitlement_ids as string[] | undefined) ??
    (event.entitlement_id ? [String(event.entitlement_id)] : []);
  const hasPremiumEntitlement =
    entitlementIds.length === 0 ||
    entitlementIds.includes("premium") ||
    String(event.entitlement_id ?? "") === "premium";

  let expirationMs: number | null = null;
  const expRaw = event.expiration_at_ms ?? event.expiration_at;
  if (typeof expRaw === "number") expirationMs = expRaw;
  else if (typeof expRaw === "string" && expRaw) {
    const n = Number(expRaw);
    if (!Number.isNaN(n)) expirationMs = n;
    else {
      const d = Date.parse(expRaw);
      if (!Number.isNaN(d)) expirationMs = d;
    }
  }

  const now = Date.now();
  let tier: "premium" | "free" = "free";
  let expiresAt: string | null = null;
  const productId = String(event.product_id ?? event.productId ?? "");
  let purchasedAtMs: number | null = null;
  const purchasedRaw = event.purchased_at_ms ?? event.purchased_at;
  if (typeof purchasedRaw === "number") purchasedAtMs = purchasedRaw;
  else if (typeof purchasedRaw === "string" && purchasedRaw) {
    const n = Number(purchasedRaw);
    if (!Number.isNaN(n)) purchasedAtMs = n;
  }

  if (PREMIUM_ACTIVE_EVENTS.has(type) && hasPremiumEntitlement) {
    tier = "premium";
    expiresAt = displayExpiryIso(productId, expirationMs, purchasedAtMs, now);
  } else if (type === "CANCELLATION" && hasPremiumEntitlement) {
    // Anulowanie – Premium do końca okresu.
    tier = "premium";
    if (expirationMs != null) expiresAt = new Date(expirationMs).toISOString();
    if (expirationMs != null && expirationMs < now) {
      tier = "free";
      expiresAt = null;
    }
  } else if (PREMIUM_INACTIVE_EVENTS.has(type) || type === "EXPIRATION") {
    if (expirationMs != null && expirationMs > now && hasPremiumEntitlement) {
      tier = "premium";
      expiresAt = new Date(expirationMs).toISOString();
    } else {
      tier = "free";
      expiresAt = null;
    }
  } else if (type === "TRANSFER" || type === "TEST") {
    // Odśwież na podstawie expiration jeśli premium entitlement.
    if (hasPremiumEntitlement && (expirationMs == null || expirationMs > now)) {
      tier = "premium";
      if (expirationMs != null) expiresAt = new Date(expirationMs).toISOString();
    }
  } else {
    // Nieznany event – ACK bez zmian.
    return new Response(JSON.stringify({ received: true, skipped: type }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const supabase = createClient(supabaseUrl, supabaseServiceKey, {
    auth: { persistSession: false },
  });

  const { data, error } = await supabase
    .from("profiles")
    .update({
      subscription_tier: tier,
      subscription_expires_at: expiresAt,
      updated_at: new Date().toISOString(),
    })
    .eq("user_id", appUserId)
    .select("user_id");

  if (error) {
    console.error("Failed to update profile:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
  if (!data || data.length === 0) {
    console.error("Profile not found for user_id:", appUserId);
  } else {
    console.log("Profile updated", { appUserId, tier, expiresAt });
  }

  return new Response(JSON.stringify({ received: true, tier }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const PROFILE_COPY_KEYS = [
  "gender",
  "age",
  "height_cm",
  "current_weight_kg",
  "target_weight_kg",
  "activity_level",
  "goal",
  "bmr",
  "tdee",
  "target_calories",
  "target_protein_g",
  "target_fat_g",
  "target_carbs_g",
  "target_date",
  "weekly_weight_change",
  "water_goal_ml",
] as const;

const TABLES_WITH_USER_ID = [
  "meals",
  "activities",
  "water_logs",
  "weight_logs",
  "body_measurements",
  "favorite_meals",
  "streaks",
  "goal_challenges",
] as const;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Brak autoryzacji" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    const authClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user: currentUser }, error: userError } = await authClient.auth.getUser();
    if (userError || !currentUser) {
      return new Response(
        JSON.stringify({ error: "Nieprawidłowa sesja" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let body: { anonymous_user_id?: string } = {};
    try {
      body = await req.json();
    } catch {
      return new Response(
        JSON.stringify({ error: "Brak anonymous_user_id w body" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }
    const anonymousUserId = body.anonymous_user_id;
    if (!anonymousUserId || typeof anonymousUserId !== "string") {
      return new Response(
        JSON.stringify({ error: "Podaj anonymous_user_id" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const targetUserId = currentUser.id;
    if (anonymousUserId === targetUserId) {
      return new Response(
        JSON.stringify({ ok: true, message: "Brak merge – ten sam użytkownik" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false },
    });

    const { data: anonymousProfile, error: profileFetchError } = await supabase
      .from("profiles")
      .select("*")
      .eq("user_id", anonymousUserId)
      .maybeSingle();

    if (profileFetchError) {
      console.error("merge-anonymous-data profile fetch:", profileFetchError);
      return new Response(
        JSON.stringify({ error: profileFetchError.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: targetProfile } = await supabase
      .from("profiles")
      .select("subscription_tier, subscription_expires_at, stripe_customer_id")
      .eq("user_id", targetUserId)
      .maybeSingle();

    if (anonymousProfile) {
      const now = new Date().toISOString();
      const updatePayload: Record<string, unknown> = {
        updated_at: now,
        user_id: targetUserId,
      };
      for (const key of PROFILE_COPY_KEYS) {
        if (anonymousProfile[key] !== undefined) {
          updatePayload[key] = anonymousProfile[key];
        }
      }
      updatePayload["subscription_tier"] = targetProfile?.subscription_tier ?? "free";
      updatePayload["subscription_expires_at"] = targetProfile?.subscription_expires_at ?? null;
      updatePayload["stripe_customer_id"] = targetProfile?.stripe_customer_id ?? null;
      const { error: profileUpsertError } = await supabase
        .from("profiles")
        .upsert(updatePayload, { onConflict: "user_id" });
      if (profileUpsertError) {
        console.error("merge-anonymous-data profile upsert:", profileUpsertError);
      }
    }

    for (const table of TABLES_WITH_USER_ID) {
      const { error: updateError } = await supabase
        .from(table)
        .update({ user_id: targetUserId })
        .eq("user_id", anonymousUserId);
      if (updateError) {
        console.error(`merge-anonymous-data ${table} update:`, updateError);
      }
    }

    try {
      const { error: goalHistoryError } = await supabase
        .from("goal_history")
        .update({ user_id: targetUserId })
        .eq("user_id", anonymousUserId);
      if (goalHistoryError) {
        console.error("merge-anonymous-data goal_history:", goalHistoryError);
      }
    } catch (e) {
      console.error("merge-anonymous-data goal_history (table may not exist):", e);
    }

    return new Response(
      JSON.stringify({ ok: true }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("merge-anonymous-data error:", err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : "Błąd serwera" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

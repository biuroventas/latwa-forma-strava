/**
 * Endpoint dla Garmin Health API (backchannel).
 * - Ping (USER_DEREG, CONNECT_ACTIVITY, dailies itd.) i Push: Garmin wysyła POST (JSON lub pusty body).
 *   Zawsze zwracamy 200 + { ok: true, received: true }.
 * - Gdy w payloadzie jest tablica "activities" (push) – zapisujemy aktywności do Supabase (mapowanie po garmin_user_id).
 * - GET/HEAD: health check – 200.
 */
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'GET, POST, HEAD, OPTIONS',
  'Cache-Control': 'no-store, max-age=0',
};

function parseBody(event) {
  const raw = event.body;
  if (!raw) return null;
  const str = event.isBase64Encoded ? Buffer.from(raw, 'base64').toString('utf8') : raw;
  try {
    return JSON.parse(str);
  } catch {
    return null;
  }
}

/** Szacowanie kcal na podstawie typu i czasu (MET * kg * h). */
function estimateCalories(activityType, durationMinutes) {
  const t = (activityType || '').toLowerCase();
  let met = 6;
  if (t.includes('run')) met = 9;
  else if (t.includes('cycle') || t.includes('bike') || t.includes('swim')) met = 8;
  else if (t.includes('hike') || t.includes('walk')) met = 5;
  else if (t.includes('yoga') || t.includes('pilates')) met = 3;
  const minutes = Math.max(1, Math.min(480, durationMinutes || 30));
  return Math.round(met * 70 * (minutes / 60)); // ~70 kg domyślnie
}

/** Jedna aktywność z push Garmin → rekord do tabeli activities. Wartości zgodne z CHECK (calories_burned >= 0, duration_minutes IS NULL OR duration_minutes > 0). */
function toActivityRow(ourUserId, a) {
  const startTimeInSeconds = a.startTimeInSeconds ?? a.startTimeGmt ?? 0;
  const durationSec = a.durationInSeconds ?? a.activeDurationInSeconds ?? 0;
  const rawMinutes = durationSec > 0 ? Math.floor(durationSec / 60) : 0;
  const durationMinutes = rawMinutes > 0 ? rawMinutes : null; // CHECK: null lub > 0, nigdy 0
  const startDate = startTimeInSeconds
    ? new Date(startTimeInSeconds * 1000).toISOString()
    : new Date().toISOString();
  const name = (a.activityName || a.activityType || 'Aktywność (Garmin)').trim();
  const displayName = (name && name.length > 0) ? `${name} (Garmin)` : 'Aktywność (Garmin)';
  // Activity API spec: activeKilocalories (integer); fallback: calories, potem szacunek
  const rawCalories = a.activeKilocalories ?? a.calories ?? estimateCalories(a.activityType, durationMinutes ?? 30);
  const calories_burned = Math.max(1, Math.round(Number(rawCalories) || 0)); // CHECK: >= 0, u nas min 1
  return {
    user_id: ourUserId,
    name: displayName,
    calories_burned,
    duration_minutes: durationMinutes,
    intensity: (a.activityType || 'OTHER').substring(0, 100) || 'OTHER',
    created_at: startDate,
  };
}

/** Zapisz aktywności z push do Supabase (wymaga SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY w env). */
async function processPushActivities(parsed) {
  const activities = parsed?.activities;
  if (!Array.isArray(activities) || activities.length === 0) return 0;

  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !serviceKey) {
    console.log('Garmin push: brak SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY – pomijam zapis aktywności');
    return 0;
  }

  const headers = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    'Content-Type': 'application/json',
    Prefer: 'return=representation',
  };

  let saved = 0;
  for (const a of activities) {
    const garminUserId = (a.userId ?? a.user_id ?? '').toString();
    if (!garminUserId) continue;

    const res = await fetch(
      `${supabaseUrl}/rest/v1/garmin_integrations?select=user_id&garmin_user_id=eq.${encodeURIComponent(garminUserId)}`,
      { headers: { ...headers, Accept: 'application/json' } }
    );
    if (!res.ok) continue;
    const rows = await res.json();
    const ourUserId = rows?.[0]?.user_id;
    if (!ourUserId) continue;

    const garminActivityId = String(a.activityId ?? a.summaryId ?? a.id ?? '');
    if (!garminActivityId) continue;

    // Nie duplikuj: jeśli już mamy tę aktywność, pomiń (idempotentność PUSH).
    const syncedCheck = await fetch(
      `${supabaseUrl}/rest/v1/garmin_synced_activities?select=id&user_id=eq.${encodeURIComponent(ourUserId)}&garmin_activity_id=eq.${encodeURIComponent(garminActivityId)}`,
      { headers: { ...headers, Accept: 'application/json' } }
    );
    if (syncedCheck.ok) {
      const existing = await syncedCheck.json();
      if (Array.isArray(existing) && existing.length > 0) continue;
    }

    const activityRow = toActivityRow(ourUserId, a);
    const insertRes = await fetch(`${supabaseUrl}/rest/v1/activities`, {
      method: 'POST',
      headers,
      body: JSON.stringify(activityRow),
    });
    if (!insertRes.ok) {
      console.warn('Garmin push: insert activity failed', insertRes.status, await insertRes.text());
      continue;
    }
    const inserted = await insertRes.json();
    const activityId = Array.isArray(inserted) ? inserted[0]?.id : inserted?.id;
    if (!activityId) continue;

    const syncedRes = await fetch(`${supabaseUrl}/rest/v1/garmin_synced_activities`, {
      method: 'POST',
      headers: { ...headers, Prefer: 'resolution=ignore-duplicates' },
      body: JSON.stringify({
        user_id: ourUserId,
        garmin_activity_id: garminActivityId,
        activity_id: activityId,
      }),
    });
    if (syncedRes.ok) saved += 1;
  }
  return saved;
}

/** Garmin: deregistrations = użytkownik odłączył app w Garmin Connect. Usuwamy integrację (zgodnie z GCDP Start Guide 2.6.2). */
async function processDeregistrations(parsed) {
  const list = parsed?.deregistrations;
  if (!Array.isArray(list) || list.length === 0) return;
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !serviceKey) return;
  const headers = { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` };
  for (const item of list) {
    const garminUserId = (item.userId ?? item.user_id ?? '').toString();
    if (!garminUserId) continue;
    const res = await fetch(
      `${supabaseUrl}/rest/v1/garmin_integrations?garmin_user_id=eq.${encodeURIComponent(garminUserId)}`,
      { method: 'DELETE', headers }
    );
    if (res.ok) console.log('[Garmin] deregistration: removed garmin_integration for', garminUserId);
  }
}

/** Garmin: userPermissionsChange zawiera userId. Jeśli mamy dokładnie jeden wiersz z garmin_user_id IS NULL, uzupełniamy (backfill). */
async function processUserPermissionsChange(parsed) {
  const list = parsed?.userPermissionsChange;
  if (!Array.isArray(list) || list.length === 0) return;
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !serviceKey) return;
  const headers = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
    'Content-Type': 'application/json',
    Prefer: 'return=minimal',
  };
  for (const item of list) {
    const garminUserId = (item.userId ?? item.user_id ?? '').toString();
    if (!garminUserId) continue;
    const checkRes = await fetch(
      `${supabaseUrl}/rest/v1/garmin_integrations?select=user_id,garmin_user_id&garmin_user_id=eq.${encodeURIComponent(garminUserId)}`,
      { headers: { ...headers, Accept: 'application/json' } }
    );
    if (checkRes.ok && (await checkRes.json()).length > 0) continue;
    const nullRes = await fetch(
      `${supabaseUrl}/rest/v1/garmin_integrations?select=user_id&garmin_user_id=is.null`,
      { headers: { ...headers, Accept: 'application/json' } }
    );
    const nullRows = nullRes.ok ? await nullRes.json() : [];
    if (nullRows.length !== 1) continue;
    const ourUserId = nullRows[0].user_id;
    const patchRes = await fetch(
      `${supabaseUrl}/rest/v1/garmin_integrations?user_id=eq.${encodeURIComponent(ourUserId)}`,
      { method: 'PATCH', headers, body: JSON.stringify({ garmin_user_id: garminUserId }) }
    );
    if (patchRes.ok) console.log('[Garmin] userPermissionsChange: backfilled garmin_user_id for', ourUserId);
  }
}

exports.handler = async function (event) {
  const method = (event.httpMethod || event.request?.method || 'GET').toUpperCase();

  if (method === 'OPTIONS') {
    return { statusCode: 204, headers: { ...CORS_HEADERS }, body: '' };
  }

  let responseBody = { ok: true, method };

  if (method === 'POST') {
    responseBody = { ok: true, received: true };
    const parsed = parseBody(event);
    const keys = parsed && typeof parsed === 'object' ? Object.keys(parsed).join(',') : 'empty';
    const bodyPreview = typeof event.body === 'string' ? event.body.substring(0, 200) : '(binary)';
    console.log('[Garmin] POST received at', new Date().toISOString(), '| body keys:', keys, '| preview:', bodyPreview);

    if (parsed?.activities?.length) {
      try {
        const saved = await processPushActivities(parsed);
        if (saved > 0) responseBody.saved_activities = saved;
      } catch (err) {
        console.warn('Garmin push process error:', err);
      }
    }
    if (parsed?.deregistrations?.length) {
      try { await processDeregistrations(parsed); } catch (e) { console.warn('Garmin deregistrations error:', e); }
    }
    if (parsed?.userPermissionsChange?.length) {
      try { await processUserPermissionsChange(parsed); } catch (e) { console.warn('Garmin userPermissionsChange error:', e); }
    }
  } else if (method === 'HEAD') {
    return {
      statusCode: 200,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      body: '',
    };
  }

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      ...CORS_HEADERS,
    },
    body: JSON.stringify(responseBody),
  };
};

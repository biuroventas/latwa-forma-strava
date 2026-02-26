/**
 * Proxy do Garmin DELETE user/registration (omija CORS w przeglądarce).
 * POST z nagłówkiem Authorization: Bearer <supabase_jwt>.
 * Pobiera access_token z garmin_integrations (Supabase), wywołuje DELETE u Garmin, zwraca 200.
 * Wymaga w Netlify: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY.
 */
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function userIdFromJwt(jwt) {
  try {
    const parts = jwt.split('.');
    if (parts.length !== 3) return null;
    const payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8'));
    return payload.sub || payload.user_id || null;
  } catch {
    return null;
  }
}

async function handler(event) {
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 204, headers: CORS, body: '' };
  }
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, headers: CORS, body: JSON.stringify({ error: 'Method not allowed' }) };
  }

  const jwt = (event.headers.authorization || event.headers.Authorization || '').replace(/^Bearer\s+/i, '').trim();
  if (!jwt) {
    return { statusCode: 401, headers: { ...CORS, 'Content-Type': 'application/json' }, body: JSON.stringify({ error: 'Missing Authorization' }) };
  }

  const userId = userIdFromJwt(jwt);
  if (!userId) {
    return { statusCode: 401, headers: { ...CORS, 'Content-Type': 'application/json' }, body: JSON.stringify({ error: 'Invalid token' }) };
  }

  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !serviceKey) {
    return { statusCode: 500, headers: { ...CORS, 'Content-Type': 'application/json' }, body: JSON.stringify({ error: 'Server config missing' }) };
  }

  try {
    const intRes = await fetch(
      `${supabaseUrl}/rest/v1/garmin_integrations?user_id=eq.${encodeURIComponent(userId)}&select=access_token`,
      { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}`, Accept: 'application/json' } }
    );
    if (!intRes.ok) {
      return { statusCode: 500, headers: { ...CORS, 'Content-Type': 'application/json' }, body: JSON.stringify({ error: 'Failed to load integration' }) };
    }
    const rows = await intRes.json();
    const accessToken = rows?.[0]?.access_token;
    if (!accessToken) {
      return { statusCode: 200, headers: { ...CORS, 'Content-Type': 'application/json' }, body: JSON.stringify({ ok: true, message: 'No integration' }) };
    }

    const delRes = await fetch('https://apis.garmin.com/wellness-api/rest/user/registration', {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    if (delRes.status !== 204 && delRes.status !== 200) {
      console.warn('Garmin DELETE registration:', delRes.status, await delRes.text());
    }
    return { statusCode: 200, headers: { ...CORS, 'Content-Type': 'application/json' }, body: JSON.stringify({ ok: true }) };
  } catch (e) {
    console.error('garmin-disconnect:', e);
    return { statusCode: 500, headers: { ...CORS, 'Content-Type': 'application/json' }, body: JSON.stringify({ error: String(e.message || e) }) };
  }
}

exports.handler = handler;

/**
 * Endpoint dla Garmin Health API (backchannel).
 * - Ping (USER_DEREG, CONNECT_ACTIVITY, dailies itd.) i Push (CONSUMER_PERMISSIONS): Garmin wysyła POST (JSON lub pusty body).
 *   Zawsze zwracamy 200 + { ok: true, received: true }, żeby Garmin zaliczył „corresponding ping request” i Endpoint Coverage Test.
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

exports.handler = async function (event) {
  const method = (event.httpMethod || event.request?.method || 'GET').toUpperCase();

  if (method === 'OPTIONS') {
    return { statusCode: 204, headers: { ...CORS_HEADERS }, body: '' };
  }

  let responseBody = { ok: true, method };

  // Każdy POST (USER_DEREG, CONSUMER_PERMISSIONS, activity itd.) – także z pustym body – zwracamy 200 + received: true,
  // żeby Garmin zaliczył „corresponding ping request” i Endpoint Coverage Test (USER_DEREG często ma pusty/minimalny payload).
  if (method === 'POST') {
    responseBody = { ok: true, received: true };
    const parsed = parseBody(event);
    const keys = parsed && typeof parsed === 'object' ? Object.keys(parsed).join(',') : 'empty';
    console.log('Garmin backchannel POST received, keys:', keys);
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

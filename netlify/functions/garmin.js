/**
 * Endpoint dla Garmin Health API – Endpoint Coverage Test (Partner Verification).
 * CONSUMER_PERMISSIONS (push) i USER_DEREG (ping) wysyłają na ten URL.
 * Zwracamy 200 dla GET/POST/HEAD, żeby Garmin zaliczył „data in the last 24 hours”.
 */
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'GET, POST, HEAD, OPTIONS',
  'Cache-Control': 'no-store, max-age=0',
};

exports.handler = async function (event) {
  const method = (event.httpMethod || event.request?.method || 'GET').toUpperCase();

  if (method === 'OPTIONS') {
    return { statusCode: 204, headers: { ...CORS_HEADERS }, body: '' };
  }

  // GET – ping (USER_DEREG), POST – push (CONSUMER_PERMISSIONS), HEAD – health check
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      ...CORS_HEADERS,
    },
    body: method === 'HEAD' ? '' : JSON.stringify({ ok: true, method }),
  };
};

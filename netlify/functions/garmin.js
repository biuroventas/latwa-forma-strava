/**
 * Endpoint dla Garmin Health API.
 * - Ping (USER_DEREG, CONNECT_ACTIVITY itd.): Garmin wysyła żądanie; musimy zwrócić 200,
 *   inaczej w logu pojawia się "Could not find corresponding ping request" przy pull.
 * - Push (CONSUMER_PERMISSIONS): POST z danymi – też 200.
 * Zwracamy zawsze 200 (oprócz OPTIONS 204), bez parsowania body – żeby każdy ping/push był zaliczony.
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

  // Wszystkie inne metody: 200. Nie parsujemy body – unikamy błędów przy dużym/nieoczekiwanym payloadzie.
  const body = method === 'HEAD' ? '' : JSON.stringify({ ok: true, method });
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      ...CORS_HEADERS,
    },
    body,
  };
};

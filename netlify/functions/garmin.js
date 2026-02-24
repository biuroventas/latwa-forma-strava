/**
 * Endpoint dla Garmin Health API – Endpoint Coverage Test.
 * CONSUMER_PERMISSIONS (push) i USER_DEREG (ping) wysyłają na ten URL.
 * Zwracamy 200, żeby Garmin zaliczył „data in the last 24 hours”.
 */
exports.handler = async function (event) {
  const method = event.httpMethod || event.request?.method || 'GET';
  // GET – ping (USER_DEREG), POST – push (CONSUMER_PERMISSIONS)
  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ok: true, method }),
  };
};

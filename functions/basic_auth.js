function handler(event) {
  var request = event.request;
  var headers = request.headers;
  var credential = "${user}:${pass}";
  var secret = `Basic $${credential.toString('base64')}`;

  if (headers.authorization && headers.authorization.value === secret) {
    return request;
  }

  return {
    statusCode: 401,
    statusDescription: 'Unauthorized',
    headers: { 'www-authenticate': { value: 'Basic' } }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../strings.dart';

enum ApiFailure implements Exception {
  invalidResponse(Dv.genericError),
  notFound(Dv.notFoundError),
  network(Dv.networkError),
  unauthorized(Dv.sessionExpiredError),
  forbidden(Dv.genericError),
  invalidCredentials(Dv.credentialsError),
  rateLimited(Dv.rateLimitedError),
  server(Dv.genericError);

  const ApiFailure(this.message);
  final String message;
}

class ApiClient {
  ApiClient(this.client, {Uri? baseUrl})
    : baseUrl = baseUrl ?? Uri.parse('https://zamzam.mv');
  final http.Client client;
  final Uri baseUrl;
  // Deliberately sends once: authentication and other requests never auto-retry.
  Future<Uint8List> request(
    String method,
    String path, {
    Map<String, Object?>? body,
    String? token,
    Duration timeout = const Duration(seconds: 10),
    bool binary = false,
  }) async {
    final request = http.Request(method, baseUrl.resolve(path));
    request.headers['Accept'] = binary ? '*/*' : 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    try {
      final response = await (() async {
        final response = await client.send(request);
        return http.Response.fromStream(response);
      })().timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      throw switch (response.statusCode) {
        401 => ApiFailure.unauthorized,
        403 => ApiFailure.forbidden,
        404 => ApiFailure.notFound,
        422 => ApiFailure.invalidCredentials,
        429 => ApiFailure.rateLimited,
        _ => ApiFailure.server,
      };
    } on ApiFailure {
      rethrow;
    } catch (_) {
      throw ApiFailure.network;
    }
  }

  Future<Map<String, dynamic>> json(
    String method,
    String path, {
    Map<String, Object?>? body,
    String? token,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final bytes = await request(
      method,
      path,
      body: body,
      token: token,
      timeout: timeout,
    );
    try {
      final value = jsonDecode(utf8.decode(bytes));
      if (value is! Map<String, dynamic>) throw const FormatException();
      return value;
    } catch (_) {
      throw ApiFailure.invalidResponse;
    }
  }
}

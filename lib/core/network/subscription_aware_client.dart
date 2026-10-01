import 'dart:convert';

import 'package:http/http.dart' as http;

/// Wraps every request the app makes (installed app-wide with
/// `http.runWithClient` in main.dart). When the backend refuses an action
/// with 403 SUBSCRIPTION_REQUIRED (subscription lapsed), it calls
/// [onSubscriptionRequired] so the paywall opens - wherever the action
/// came from - instead of each screen showing a generic error.
class SubscriptionAwareClient extends http.BaseClient {
  final http.Client _inner;
  final void Function() onSubscriptionRequired;

  SubscriptionAwareClient(this._inner, {required this.onSubscriptionRequired});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode != 403) return response;

    // Small error body: buffer it to inspect, then hand back an identical
    // response so the caller still sees the 403.
    final bytes = await response.stream.toBytes();
    if (utf8.decode(bytes, allowMalformed: true).contains('SUBSCRIPTION_REQUIRED')) {
      onSubscriptionRequired();
    }
    return http.StreamedResponse(
      http.ByteStream.fromBytes(bytes),
      response.statusCode,
      contentLength: bytes.length,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();
}

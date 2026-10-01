import 'package:cooked/core/network/subscription_aware_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('403 SUBSCRIPTION_REQUIRED triggers the paywall and keeps the response', () async {
    var triggered = 0;
    final client = SubscriptionAwareClient(
      MockClient((_) async => http.Response(
          '{"error":"Active subscription required","code":"SUBSCRIPTION_REQUIRED"}', 403)),
      onSubscriptionRequired: () => triggered++,
    );
    final res = await client.post(Uri.parse('https://api.test/recipes/scan'));
    expect(res.statusCode, 403);
    expect(res.body, contains('SUBSCRIPTION_REQUIRED'));
    expect(triggered, 1);
  });

  test('other responses pass through untouched', () async {
    var triggered = 0;
    final client = SubscriptionAwareClient(
      MockClient((req) async => req.url.path == '/forbidden'
          ? http.Response('{"error":"Forbidden"}', 403)
          : http.Response('ok', 200)),
      onSubscriptionRequired: () => triggered++,
    );
    expect((await client.get(Uri.parse('https://api.test/ok'))).body, 'ok');
    expect((await client.get(Uri.parse('https://api.test/forbidden'))).statusCode, 403);
    expect(triggered, 0);
  });
}

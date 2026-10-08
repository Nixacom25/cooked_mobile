import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import 'auth_service.dart';

/// Usage events for the admin analytics (sessions, recipe views, web search
/// clicks / saves). Queued and sent in batches; never blocks the UI and
/// silently drops events when signed out or offline.
class AppEventsService {
  AppEventsService._();
  static final AppEventsService instance = AppEventsService._();

  static const _maxQueue = 200;
  static const _batch = 50;

  final List<Map<String, dynamic>> _queue = [];
  Timer? _timer;
  DateTime? _sessionStart;
  bool _sending = false;

  void track(String type, {String? detail, int? durationMs}) {
    if (_queue.length >= _maxQueue) _queue.removeAt(0);
    _queue.add({
      'type': type,
      if (detail != null && detail.isNotEmpty) 'detail': detail.length > 160 ? detail.substring(0, 160) : detail,
      if (durationMs != null) 'durationMs': durationMs,
    });
    _timer ??= Timer(const Duration(seconds: 30), flush);
  }

  /// App came to the foreground.
  void sessionStarted() => _sessionStart = DateTime.now();

  /// App went to the background: record the session length and send everything.
  void sessionEnded() {
    final start = _sessionStart;
    _sessionStart = null;
    if (start != null) {
      final ms = DateTime.now().difference(start).inMilliseconds;
      if (ms >= 1000) track('APP_SESSION', durationMs: ms.clamp(0, 86400000));
    }
    flush();
  }

  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    if (_sending || _queue.isEmpty) return;
    _sending = true;
    try {
      final token = await AuthService.instance.getToken();
      if (token == null) {
        _queue.clear();
        return;
      }
      while (_queue.isNotEmpty) {
        final batch = _queue.take(_batch).toList();
        final res = await http
            .post(Uri.parse('${ApiConfig.baseUrl}/events'),
                headers: ApiConfig.authHeaders(token), body: jsonEncode({'events': batch}))
            .timeout(const Duration(seconds: 10));
        if (res.statusCode >= 500) break; // keep them for the next flush
        _queue.removeRange(0, batch.length);
      }
    } catch (_) {
      // offline: retried on the next flush
    } finally {
      _sending = false;
    }
  }
}

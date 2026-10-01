import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Page tracking with PostHog (https://us.posthog.com).
///
/// Keys come from the build, never from the source:
///   flutter run/build ... --dart-define=POSTHOG_API_KEY=phc_xxx
///                         --dart-define=POSTHOG_HOST=https://us.i.posthog.com
/// Without POSTHOG_API_KEY nothing is sent (local/dev builds).
///
/// Tracked: every named route (via [observer]) plus the bottom tabs, which
/// live inside one route. Users are identified by their Cooked id only - no
/// email or name is sent.
class PostHogService {
  PostHogService._();
  static final PostHogService instance = PostHogService._();

  static const String _apiKey = String.fromEnvironment('POSTHOG_API_KEY');
  static const String _host =
      String.fromEnvironment('POSTHOG_HOST', defaultValue: 'https://us.i.posthog.com');

  static const List<String> _tabNames = ['home', 'explore', 'scan', 'grocery', 'import'];

  bool _ready = false;
  String? _identifiedUserId;

  bool get enabled => _apiKey.isNotEmpty;

  /// Route observer for MaterialApp.navigatorObservers (null when PostHog is
  /// disabled). One instance, so app rebuilds don't swap observers.
  late final NavigatorObserver? observer = enabled ? PosthogObserver() : null;

  Future<void> init() async {
    if (!enabled || _ready) return;
    try {
      final config = PostHogConfig(_apiKey)
        ..host = _host
        ..debug = kDebugMode
        ..captureApplicationLifecycleEvents = true
        // Pushes are handled by Firebase; don't hand device tokens to PostHog.
        ..capturePushNotificationSubscriptions = false
        ..capturePushNotificationOpened = false;
      await Posthog().setup(config);
      _ready = true;
    } catch (_) {
      // Analytics must never block the app.
    }
  }

  /// Bottom-tab switches (Home, Explore, Scan, Grocery, Import).
  void trackTab(int index) {
    if (!_ready || index < 0 || index >= _tabNames.length) return;
    Posthog().screen(screenName: 'tab_${_tabNames[index]}').catchError((_) {});
  }

  /// Links events to the signed-in account (by id), or resets on sign-out.
  void syncUser(String? userId) {
    if (!_ready) return;
    if (userId != null && userId.isNotEmpty) {
      if (userId == _identifiedUserId) return;
      _identifiedUserId = userId;
      Posthog().identify(userId: userId).catchError((_) {});
    } else if (_identifiedUserId != null) {
      _identifiedUserId = null;
      Posthog().reset().catchError((_) {});
    }
  }
}

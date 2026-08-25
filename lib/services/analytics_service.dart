import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._privateConstructor();
  static final AnalyticsService instance = AnalyticsService._privateConstructor();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      print('📊 [Analytics] Event logged: $name ${parameters ?? ''}');
    } catch (e) {
      print('⚠️ [Analytics] Failed to log event $name: $e');
    }
  }

  // ── Grocery List & Instacart Analytics Events ────────────────────────────────

  Future<void> logGroceryListView({int itemCount = 0}) async {
    await logEvent('grocery_list_view', parameters: {'item_count': itemCount});
  }

  Future<void> logGroceryItemAdded({required String name, String? source}) async {
    await logEvent('grocery_item_added', parameters: {
      'item_name': name,
      if (source != null) 'source': source,
    });
  }

  Future<void> logGroceryItemRemoved({required String name}) async {
    await logEvent('grocery_item_removed', parameters: {'item_name': name});
  }

  Future<void> logInstacartCtaView({int itemCount = 0}) async {
    await logEvent('instacart_cta_view', parameters: {'item_count': itemCount});
  }

  Future<void> logInstacartCtaClicked({int itemCount = 0}) async {
    await logEvent('instacart_cta_clicked', parameters: {'item_count': itemCount});
  }

  Future<void> logInstacartRequestStarted({int itemCount = 0}) async {
    await logEvent('instacart_request_started', parameters: {'item_count': itemCount});
  }

  Future<void> logInstacartRequestSuccess({required String url, int itemCount = 0}) async {
    await logEvent('instacart_request_success', parameters: {
      'url': url,
      'item_count': itemCount,
    });
  }

  Future<void> logInstacartRequestFailed({required String error}) async {
    await logEvent('instacart_request_failed', parameters: {'error': error});
  }

  Future<void> logInstacartRedirectSuccess({required String mode}) async {
    await logEvent('instacart_redirect_success', parameters: {'mode': mode});
  }

  Future<void> logInstacartRedirectFailed({required String error}) async {
    await logEvent('instacart_redirect_failed', parameters: {'error': error});
  }
}

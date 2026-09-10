import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._privateConstructor();
  static final AnalyticsService instance = AnalyticsService._privateConstructor();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('📊 [Analytics] Event logged: $name ${parameters ?? ''}');
    } catch (e) {
      debugPrint('⚠️ [Analytics] Failed to log event $name: $e');
    }
  }

  // ── Grocery List Analytics Events ─────────────────────────────────────────────

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
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SharingService {
  static final SharingService instance = SharingService._();
  SharingService._();

  StreamSubscription? _intentDataStreamSubscription;
  final ValueNotifier<String?> sharedTextNotifier = ValueNotifier<String?>(null);

  void init() {
    // For sharing or opening urls from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        for (final item in value) {
          final url = extractUrl(item.path);
          if (url != null) {
            debugPrint("Received shared URL (stream): $url");
            sharedTextNotifier.value = url;
            return;
          }
        }
        // Fallback to first path if no URL found in any item
        sharedTextNotifier.value = value.first.path;
      }
    }, onError: (err) {
      debugPrint("getMediaStream error: $err");
    });

    // For sharing or opening urls from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        for (final item in value) {
          final url = extractUrl(item.path);
          if (url != null) {
            debugPrint("Received shared URL (initial): $url");
            sharedTextNotifier.value = url;
            return;
          }
        }
        sharedTextNotifier.value = value.first.path;
      }
    });
  }

  String? extractUrl(String text) {
    if (text.isEmpty) return null;
    final trimmed = text.trim();
    
    // If the text itself is a URL
    if (trimmed.startsWith('http')) {
      return trimmed.split(RegExp(r'\s')).first;
    }

    final urlRegExp = RegExp(r'(https?://[^\s]+)');
    final match = urlRegExp.firstMatch(text);
    return match?.group(0);
  }

  void consumeSharedText() {
    sharedTextNotifier.value = null;
  }

  void dispose() {
    _intentDataStreamSubscription?.cancel();
  }
}

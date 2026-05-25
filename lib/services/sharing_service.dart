import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharingService {
  static final SharingService instance = SharingService._();
  SharingService._();

  StreamSubscription? _intentDataStreamSubscription;
  final ValueNotifier<String?> sharedTextNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> clipboardTextNotifier = ValueNotifier<String?>(null);
  String? _lastClipboardText;

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

  static const _clipboardChannel = MethodChannel('com.cooked.app/clipboard');

  Future<void> checkClipboard() async {
    if (Platform.isIOS) {
      try {
        final hasWebUrl = await _clipboardChannel.invokeMethod<bool>('hasWebURL');
        if (hasWebUrl != true) return;
      } catch (e) {
        debugPrint("Clipboard channel error: $e");
        return;
      }
    }

    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      
      if (text != null && text.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final storedLastText = prefs.getString('last_clipboard_text');
        
        // Use stored value if _lastClipboardText is null (e.g. on app restart)
        _lastClipboardText ??= storedLastText;

        if (text != _lastClipboardText) {
          _lastClipboardText = text;
          await prefs.setString('last_clipboard_text', text);
          
          final url = extractUrl(text);
          if (url != null && _isValidRecipeOrSocialUrl(url)) {
            clipboardTextNotifier.value = url;
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking clipboard: $e");
    }
  }

  bool _isValidRecipeOrSocialUrl(String urlString) {
    try {
      final uri = Uri.tryParse(urlString);
      if (uri == null) return false;

      final scheme = uri.scheme.toLowerCase();
      if (scheme != 'http' && scheme != 'https') return false;

      final host = uri.host.toLowerCase();
      if (host.isEmpty || !host.contains('.')) return false;

      final path = uri.path.toLowerCase();
      
      // 1. Social Platforms (TikTok, YouTube, Facebook, Instagram)
      if (host.contains('tiktok.com') || 
          host.contains('youtube.com') || 
          host.contains('youtu.be') || 
          host.contains('facebook.com') || 
          host.contains('fb.watch') || 
          host.contains('instagram.com') ||
          host.contains('instagr.am')) {
        return true;
      }
      
      // 2. Popular recipe platforms & keywords
      final recipeKeywords = [
        'recipe', 'recette', 'cook', 'cuisine', 'food', 'kitchen', 'dish',
        'marmiton', '750g', 'cuisineaz', 'delish', 'allrecipes',
        'epicurious', 'tasty', 'bonappetit', 'seriouseats',
        'simplyrecipes', 'marthastewart', 'foodnetwork', 'chef',
        'bakery', 'baking', 'culinary', 'gourmet', 'supertoinette',
        'ptitchef', 'chefsimon'
      ];
      
      for (final keyword in recipeKeywords) {
        if (host.contains(keyword) || path.contains(keyword)) {
          return true;
        }
      }
      
      return false;
    } catch (_) {
      return false;
    }
  }

  void ignoreClipboard() {
    clipboardTextNotifier.value = null;
  }

  String? extractUrl(String text) {
    if (text.isEmpty) return null;
    final trimmed = text.trim();
    
    // If the text itself is a URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
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

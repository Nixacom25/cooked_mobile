import '../l10n/l10n.dart';

class ErrorHelper {
  static String getFriendlyMessage(dynamic e) {
    if (e == null) return appL10n.errUnexpected;
    final str = e.toString();

    // Extract JSON error message if the backend sends a raw payload like {"status":400,"message":"...","source":"IA"}
    if (str.contains('{"') && str.contains('"message"')) {
      try {
        final msgReg = RegExp(r'"message"\s*:\s*"([^"]+)"');
        final srcReg = RegExp(r'"source"\s*:\s*"([^"]+)"');

        final msgMatch = msgReg.firstMatch(str);
        final srcMatch = srcReg.firstMatch(str);

        if (msgMatch != null) {
          String msg = msgMatch.group(1)!;
          if (srcMatch != null) {
            String src = srcMatch.group(1)!;
            if (src == "IA") return appL10n.errAi(msg);
            if (src == "BACKEND") return appL10n.errServer(msg);
            if (src == "VALIDATION") return appL10n.errInput(msg);
            if (src == "AUTH") return appL10n.errAuth(msg);
          }
          return msg;
        }
      } catch (_) {}
    }

    // Explicit friendly UI messages passed through
    if (str.contains('verify your network') ||
        str.contains('Invalid email') ||
        str.contains('Password') ||
        str.contains('Code sent') ||
        str.contains('Subscription activated') ||
        str.contains('Could not initiate purchase') ||
        str.contains('storekit') ||
        str.contains('Store not available')) {
      return str.replaceAll('Exception: ', '');
    }

    // Backend standardizations
    final lower = str.toLowerCase();
    if (str.startsWith('402:') || lower.contains('payment required')) {
      return appL10n.errPremiumRequired;
    }
    if (lower.contains('notfound') || lower.contains('not found')) {
      return appL10n.errNotFound;
    }
    if (lower.contains('unauthorized') ||
        lower.contains('expiredjwtexception') ||
        lower.contains('invalid token')) {
      return appL10n.errSessionExpired;
    }
    if (lower.contains('socketexception') ||
        lower.contains('timeoutexception') ||
        lower.contains('connection refused') ||
        lower.contains('network')) {
      return appL10n.errNoInternet;
    }
    if (lower.contains('already exists') || lower.contains('duplicate') || lower.contains('exists already')) {
      if (lower.contains('email') || lower.contains('account') || lower.contains('user')) {
        return appL10n.errAccountExists;
      }
      return appL10n.errItemExists;
    }
    if (lower.contains('invalid verification code') || lower.contains('otp')) {
      return appL10n.errInvalidCode;
    }
    if (lower.contains('inexistant') || (lower.contains('not found') && lower.contains('user')) || lower.contains('account not found')) {
      return appL10n.errAccountNotFound;
    }

    if (lower.contains('429') || lower.contains('too many requests') || lower.contains('quota')) {
      return appL10n.errServersBusy;
    }
    if (lower.contains('extraction failed') || lower.contains('extract recipe') || lower.contains('couldn\'t find the complete recipe')) {
      return appL10n.errExtractFailed;
    }
    if (lower.contains('scraping') || lower.contains('blocking us') || lower.contains('http error')) {
      return appL10n.errSiteBlocking;
    }

    // Fallback logic
    if (str.startsWith('Exception: ')) {
      // If the exception contains weird technical characters like <EOL> or HTML or JSON, it's a raw backend error
      if (str.contains('<') || str.contains('{') || str.contains('429') || str.contains('500') || str.contains('Failed to')) {
          return appL10n.errGeneric;
      }
      return str.replaceAll('Exception: ', '');
    }

    return appL10n.errGeneric;
  }
}

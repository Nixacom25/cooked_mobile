class ErrorHelper {
  static String getFriendlyMessage(dynamic e) {
    if (e == null) return 'An unexpected error occurred.';
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
            if (src == "IA") return "🤖 IA Error: $msg";
            if (src == "BACKEND") return "⚙️ Server Error: $msg";
            if (src == "VALIDATION") return "📝 Input Error: $msg";
            if (src == "AUTH") return "🔒 Auth Error: $msg";
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
      return 'Premium access required. Please check your subscription.';
    }
    if (lower.contains('notfound') || lower.contains('not found')) {
      return 'The requested item was not found.';
    }
    if (lower.contains('unauthorized') ||
        lower.contains('expiredjwtexception') ||
        lower.contains('invalid token')) {
      return 'Session expired or invalid. Please log in again.';
    }
    if (lower.contains('socketexception') ||
        lower.contains('timeoutexception') ||
        lower.contains('connection refused') ||
        lower.contains('network')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (lower.contains('already exists') || lower.contains('duplicate') || lower.contains('exists already')) {
      if (lower.contains('email') || lower.contains('account') || lower.contains('user')) {
        return 'This account already exists. Please log in.';
      }
      return 'This item already exists.';
    }
    if (lower.contains('invalid verification code') || lower.contains('otp')) {
      return 'Invalid verification code. Please try again.';
    }
    if (lower.contains('inexistant') || (lower.contains('not found') && lower.contains('user')) || lower.contains('account not found')) {
      return 'Account not found. Please sign up via onboarding.';
    }

    if (lower.contains('429') || lower.contains('too many requests') || lower.contains('quota')) {
      return 'Our servers are currently busy. Please try again in a moment.';
    }
    if (lower.contains('extraction failed')) {
      return 'Failed to extract recipe from this link. Please check the URL or try another one.';
    }

    // Fallback logic
    if (str.startsWith('Exception: ')) {
      // If the exception contains weird technical characters like <EOL> or HTML or JSON, it's a raw backend error
      if (str.contains('<') || str.contains('{') || str.contains('429') || str.contains('500') || str.contains('Failed to')) {
          return 'Something went wrong. Please try again later.';
      }
      return str.replaceAll('Exception: ', '');
    }

    return 'Something went wrong. Please try again later.';
  }
}

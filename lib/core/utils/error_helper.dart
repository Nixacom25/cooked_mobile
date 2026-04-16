class ErrorHelper {
  static String getFriendlyMessage(dynamic e) {
    if (e == null) return 'An unexpected error occurred.';
    final str = e.toString();

    // Extract JSON error message if the backend sends a raw payload like {"status":400,"message":"You already have a recipe named..."}
    if (str.contains('{"') && str.contains('"message"')) {
      try {
        final regExp = RegExp(r'"message"\s*:\s*"([^"]+)"');
        final match = regExp.firstMatch(str);
        if (match != null) {
          return match.group(
            1,
          )!; // This will return exactly "You already have a recipe named '...'"
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
        str.contains('Store not available')) {
      return str.replaceAll('Exception: ', '');
    }

    // Backend standardizations
    final lower = str.toLowerCase();
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
    if (lower.contains('already exists') || lower.contains('duplicate')) {
      return 'This item already exists.';
    }
    if (lower.contains('invalid verification code') || lower.contains('otp')) {
      return 'Invalid verification code. Please try again.';
    }

    // Fallback logic
    if (str.startsWith('Exception: ')) {
      // if it's a clean exception message thrown locally
      return str.replaceAll('Exception: ', '');
    }

    return 'Something went wrong. Please try again later.';
  }
}

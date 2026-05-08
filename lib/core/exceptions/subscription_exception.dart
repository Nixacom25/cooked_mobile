class SubscriptionRequiredException implements Exception {
  final String message;
  SubscriptionRequiredException([this.message = 'Subscription required to access this feature']);
  
  @override
  String toString() => message;
}

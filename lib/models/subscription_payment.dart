class SubscriptionPayment {
  final String id;
  final double amount;
  final String planType;
  final String status;
  final String stripePaymentId;
  final DateTime createdAt;

  SubscriptionPayment({
    required this.id,
    required this.amount,
    required this.planType,
    required this.status,
    required this.stripePaymentId,
    required this.createdAt,
  });

  factory SubscriptionPayment.fromJson(Map<String, dynamic> json) {
    return SubscriptionPayment(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      planType: json['planType'] ?? '',
      status: json['status'] ?? '',
      stripePaymentId: json['stripePaymentId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

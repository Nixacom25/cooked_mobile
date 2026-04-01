class Order {
  final String id;
  final String firstName;
  final String lastName;
  final String primaryPhone;
  final String? secondaryPhone;
  final String? googleMapsLink;
  final String deliveryDate;
  final String deliveryTime;
  final String? comments;
  final List<OrderItem> items;
  final int totalAmount;
  final DateTime createdAt;
  final OrderStatus status;

  Order({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.primaryPhone,
    this.secondaryPhone,
    this.googleMapsLink,
    required this.deliveryDate,
    required this.deliveryTime,
    this.comments,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.status = OrderStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'primaryPhone': primaryPhone,
      'secondaryPhone': secondaryPhone,
      'googleMapsLink': googleMapsLink,
      'deliveryDate': deliveryDate,
      'deliveryTime': deliveryTime,
      'comments': comments,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final clientJson = json['client'] as Map<String, dynamic>?;
    return Order(
      id: json['id'] ?? '',
      firstName: clientJson?['firstName'] ?? json['firstName'] ?? '',
      lastName: clientJson?['lastName'] ?? json['lastName'] ?? '',
      primaryPhone: clientJson?['phone'] ?? json['primaryPhone'] ?? '',
      secondaryPhone: json['secondaryPhone'],
      googleMapsLink: json['googleMapsLink'],
      deliveryDate: json['deliveryDate']?.toString() ?? '',
      deliveryTime: json['deliveryTime'] ?? '',
      comments: json['notes'] ?? json['comments'],
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      status: OrderStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == (json['status'] as String?)?.toLowerCase(),
        orElse: () => OrderStatus.pending,
      ),
    );
  }
}

class OrderItem {
  final String productId;
  final String productTitle;
  final String productCategory;
  final int quantity;
  final int unitPrice;
  final int deliveryFee;
  final bool includeInstallation;
  final int installationFee;
  final int total;

  OrderItem({
    required this.productId,
    required this.productTitle,
    required this.productCategory,
    required this.quantity,
    required this.unitPrice,
    required this.deliveryFee,
    required this.includeInstallation,
    required this.installationFee,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'productCategory': productCategory,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'deliveryFee': deliveryFee,
      'includeInstallation': includeInstallation,
      'installationFee': installationFee,
      'total': total,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;
    return OrderItem(
      productId: productJson?['id'] ?? json['productId'] ?? '',
      productTitle: productJson?['title'] ?? json['productTitle'] ?? '',
      productCategory:
          productJson?['category'] ?? json['productCategory'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toInt() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toInt() ?? 0,
      includeInstallation:
          json['assemblyIncluded'] ?? json['includeInstallation'] ?? false,
      installationFee: (json['installationFee'] as num?)?.toInt() ?? 0,
      total:
          (json['total'] as num?)?.toInt() ??
          ((json['unitPrice'] ?? 0) * (json['quantity'] ?? 1)),
    );
  }
}

enum OrderStatus {
  pending, // En attente
  confirmed, // Confirmée
  preparing, // En préparation
  shipping, // En livraison
  delivered, // Livrée
  cancelled, // Annulée
}

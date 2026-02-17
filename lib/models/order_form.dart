enum DeliveryDate { today, tomorrow, other }

enum DeliveryTime { asap, anytime, specific }

class OrderForm {
  // Client info
  String firstName;
  String lastName;
  String primaryPhone;
  String? secondaryPhone;

  // Location
  String? googleMapsLink;

  // Delivery
  DeliveryDate deliveryDate;
  String? otherDate; // If deliveryDate == other
  DeliveryTime deliveryTime;
  String? specificTime; // If deliveryTime == specific

  // Comments
  String? comments;

  OrderForm({
    this.firstName = '',
    this.lastName = '',
    this.primaryPhone = '',
    this.secondaryPhone,
    this.googleMapsLink,
    this.deliveryDate = DeliveryDate.today,
    this.otherDate,
    this.deliveryTime = DeliveryTime.asap,
    this.specificTime,
    this.comments,
  });

  // Validation
  bool get isValid {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        primaryPhone.isNotEmpty &&
        googleMapsLink != null &&
        googleMapsLink!.isNotEmpty;
  }

  // Get delivery date text
  String get deliveryDateText {
    switch (deliveryDate) {
      case DeliveryDate.today:
        return 'Aujourd\'hui';
      case DeliveryDate.tomorrow:
        return 'Demain';
      case DeliveryDate.other:
        return otherDate ?? 'Autre date';
    }
  }

  // Get delivery time text
  String get deliveryTimeText {
    switch (deliveryTime) {
      case DeliveryTime.asap:
        return 'Le plus rapidement possible';
      case DeliveryTime.anytime:
        return 'Disponible à tout moment';
      case DeliveryTime.specific:
        return specificTime ?? 'Heure précise';
    }
  }
}

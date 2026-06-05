class PaymentCard {
  final int id;
  final int userId;
  final String cardHolder;
  final String cardNumberLast4;
  final String cardType;
  final String expiryDate;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentCard({
    required this.id,
    required this.userId,
    required this.cardHolder,
    required this.cardNumberLast4,
    required this.cardType,
    required this.expiryDate,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      cardHolder: json['card_holder'] as String,
      cardNumberLast4: json['card_number_last4'] as String,
      cardType: json['card_type'] as String,
      expiryDate: json['expiry_date'] as String,
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_holder': cardHolder,
      'card_number_last4': cardNumberLast4,
      'card_type': cardType,
      'expiry_date': expiryDate,
      'is_default': isDefault,
    };
  }

  String get maskedCardNumber => '**** **** **** $cardNumberLast4';
  
  String get cardTypeDisplay {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      case 'discover':
        return 'Discover';
      default:
        return cardType;
    }
  }
}

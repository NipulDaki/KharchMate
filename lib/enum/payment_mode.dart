import 'package:flutter/material.dart';

enum PaymentMode {
  upi,
  card,
  bank,
  cash;

  String get displayName {
    switch (this) {
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.bank:
        return 'Bank';
      case PaymentMode.cash:
        return 'Cash';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMode.upi:
        return Icons.qr_code_rounded;
      case PaymentMode.card:
        return Icons.credit_card_rounded;
      case PaymentMode.bank:
        return Icons.account_balance_rounded;
      case PaymentMode.cash:
        return Icons.payments_rounded;
    }
  }

  static PaymentMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'upi':
        return PaymentMode.upi;
      case 'card':
        return PaymentMode.card;
      case 'bank':
        return PaymentMode.bank;
      case 'cash':
      default:
        return PaymentMode.cash;
    }
  }
}

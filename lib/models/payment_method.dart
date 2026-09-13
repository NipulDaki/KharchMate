import 'package:flutter/material.dart';
import 'package:kharch_mate/database/database_constants.dart';

class PaymentMethodModel {
  final int? id;
  final String name;
  final String type; // 'cash' | 'bank' | 'card' | 'upi'
  final String? icon;
  final bool isDefault;
  final DateTime createdAt;

  const PaymentMethodModel({
    this.id,
    required this.name,
    required this.type,
    this.icon,
    this.isDefault = false,
    required this.createdAt,
  });

  IconData get iconData {
    switch (type.toLowerCase()) {
      case 'bank':
        return Icons.account_balance_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'upi':
        return Icons.qr_code_rounded;
      case 'cash':
      default:
        return Icons.payments_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.colPaymentMethodId: id,
      DatabaseConstants.colPaymentMethodName: name,
      DatabaseConstants.colPaymentMethodType: type,
      DatabaseConstants.colPaymentMethodIcon: icon,
      DatabaseConstants.colPaymentMethodIsDefault: isDefault ? 1 : 0,
      DatabaseConstants.colPaymentMethodCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map[DatabaseConstants.colPaymentMethodId] as int?,
      name: map[DatabaseConstants.colPaymentMethodName] as String? ?? '',
      type: map[DatabaseConstants.colPaymentMethodType] as String? ?? 'cash',
      icon: map[DatabaseConstants.colPaymentMethodIcon] as String?,
      isDefault:
          (map[DatabaseConstants.colPaymentMethodIsDefault] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(
            map[DatabaseConstants.colPaymentMethodCreatedAt] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}

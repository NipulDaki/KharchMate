import 'package:flutter/material.dart';
import 'package:kharch_mate/database/database_constants.dart';

enum CategoryType {
  expense,
  income,
  both;

  static CategoryType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'income':
        return CategoryType.income;
      case 'both':
        return CategoryType.both;
      case 'expense':
      default:
        return CategoryType.expense;
    }
  }

  String toDbString() {
    switch (this) {
      case CategoryType.expense:
        return 'expense';
      case CategoryType.income:
        return 'income';
      case CategoryType.both:
        return 'both';
    }
  }
}

class CategoryModel {
  final int? id;
  final String name;
  final CategoryType type;
  final String icon;
  final String color;
  final bool isDefault;
  final DateTime createdAt;

  const CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
  });

  CategoryModel copyWith({
    int? id,
    String? name,
    CategoryType? type,
    String? icon,
    String? color,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Color get colorValue {
    try {
      final hex = color.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      } else if (hex.length == 8) {
        return Color(int.parse('0x$hex'));
      }
    } catch (_) {}
    return Colors.grey;
  }

  IconData get iconData {
    switch (icon.toLowerCase()) {
      case 'fastfood':
      case 'food':
      case 'restaurant':
        return Icons.restaurant;
      case 'home':
      case 'rent':
        return Icons.home_rounded;
      case 'directions_car':
      case 'transport':
      case 'car':
        return Icons.directions_car_rounded;
      case 'shopping_bag':
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'receipt_long':
      case 'receipt':
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'movie':
      case 'entertainment':
        return Icons.movie_rounded;
      case 'sports_esports':
      case 'gamepad':
      case 'gaming':
        return Icons.sports_esports_rounded;
      case 'school':
      case 'education':
        return Icons.school_rounded;
      case 'flight':
      case 'travel':
      case 'airplane':
        return Icons.flight_rounded;
      case 'spa':
      case 'personal_care':
      case 'wellness':
        return Icons.spa_rounded;
      case 'shopping_cart':
      case 'groceries':
        return Icons.shopping_cart_rounded;
      case 'account_balance':
      case 'bank':
      case 'loans':
      case 'emi':
        return Icons.account_balance_rounded;
      case 'shield':
      case 'insurance':
      case 'security':
        return Icons.shield_rounded;
      case 'medical_services':
      case 'health':
        return Icons.medical_services_rounded;
      case 'more_horiz':
      case 'other':
      case 'others':
        return Icons.more_horiz_rounded;
      case 'account_balance_wallet':
      case 'salary':
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'stars':
      case 'star':
      case 'bonus':
      case 'reward':
        return Icons.stars_rounded;
      case 'percent':
      case 'interest':
        return Icons.percent_rounded;
      case 'laptop_mac':
      case 'freelance':
      case 'work':
        return Icons.laptop_mac_rounded;
      case 'store':
      case 'business':
        return Icons.store_rounded;
      case 'trending_up':
      case 'investment':
        return Icons.trending_up_rounded;
      case 'card_giftcard':
      case 'gift':
      case 'gifts':
        return Icons.card_giftcard_rounded;
      case 'attach_money':
      case 'money':
        return Icons.attach_money_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.colCategoryId: id,
      DatabaseConstants.colCategoryName: name,
      DatabaseConstants.colCategoryType: type.toDbString(),
      DatabaseConstants.colCategoryIcon: icon,
      DatabaseConstants.colCategoryColor: color,
      DatabaseConstants.colCategoryIsDefault: isDefault ? 1 : 0,
      DatabaseConstants.colCategoryCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[DatabaseConstants.colCategoryId] as int?,
      name: map[DatabaseConstants.colCategoryName] as String? ?? '',
      type: CategoryType.fromString(
        map[DatabaseConstants.colCategoryType] as String? ?? 'expense',
      ),
      icon: map[DatabaseConstants.colCategoryIcon] as String? ?? 'category',
      color: map[DatabaseConstants.colCategoryColor] as String? ?? '#808080',
      isDefault:
          (map[DatabaseConstants.colCategoryIsDefault] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(
            map[DatabaseConstants.colCategoryCreatedAt] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}

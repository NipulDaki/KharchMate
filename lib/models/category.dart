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

  IconData get iconData => iconDataFrom(icon, name);

  /// Resolves an [IconData] given an [icon] string key and/or a category [name].
  /// Matches known icon keys first, then known category name mappings,
  /// followed by keyword heuristic checks on the name.
  static IconData iconDataFrom(String? icon, [String? name]) {
    // 1. Try matching the icon key if valid and not generic 'category'
    final rawIcon = icon?.trim().toLowerCase();
    if (rawIcon != null && rawIcon.isNotEmpty && rawIcon != 'category') {
      final iconMatch = _matchKeyToIcon(rawIcon);
      if (iconMatch != null) return iconMatch;
    }

    // 2. Try matching the name as an icon key or known keyword
    final rawName = name?.trim().toLowerCase();
    if (rawName != null && rawName.isNotEmpty) {
      final nameKeyMatch = _matchKeyToIcon(rawName);
      if (nameKeyMatch != null) return nameKeyMatch;

      // 3. Keyword / substring heuristic matching on category name
      final heuristicMatch = _matchNameHeuristics(rawName);
      if (heuristicMatch != null) return heuristicMatch;
    }

    return Icons.category_rounded;
  }

  static IconData? _matchKeyToIcon(String key) {
    switch (key.toLowerCase()) {
      case 'fastfood':
      case 'food':
      case 'restaurant':
      case 'flatware':
      case 'dining':
      case 'eat':
      case 'meals':
        return Icons.restaurant;
      case 'home':
      case 'rent':
      case 'house':
      case 'apartment':
      case 'housing':
        return Icons.home_rounded;
      case 'directions_car':
      case 'transport':
      case 'transportation':
      case 'car':
      case 'vehicle':
      case 'commute':
      case 'fuel':
      case 'petrol':
      case 'diesel':
      case 'cab':
      case 'taxi':
        return Icons.directions_car_rounded;
      case 'shopping_bag':
      case 'shopping':
      case 'clothes':
      case 'clothing':
      case 'apparel':
        return Icons.shopping_bag_rounded;
      case 'shopping_cart':
      case 'groceries':
      case 'grocery':
      case 'supermarket':
      case 'market':
        return Icons.shopping_cart_rounded;
      case 'receipt_long':
      case 'receipt':
      case 'bills':
      case 'bill':
      case 'utilities':
      case 'electricity':
      case 'water':
      case 'utility':
      case 'recharge':
      case 'wifi':
      case 'internet':
        return Icons.receipt_long_rounded;
      case 'movie':
      case 'entertainment':
      case 'movies':
      case 'cinema':
      case 'theatre':
      case 'theater':
      case 'netflix':
      case 'ott':
        return Icons.movie_rounded;
      case 'sports_esports':
      case 'gamepad':
      case 'gaming':
      case 'game':
      case 'games':
      case 'esports':
        return Icons.sports_esports_rounded;
      case 'school':
      case 'education':
      case 'college':
      case 'university':
      case 'tuition':
      case 'studies':
      case 'course':
      case 'books':
        return Icons.school_rounded;
      case 'flight':
      case 'travel':
      case 'airplane':
      case 'plane':
      case 'trip':
      case 'tour':
      case 'vacation':
      case 'holiday':
        return Icons.flight_rounded;
      case 'spa':
      case 'personal_care':
      case 'personal care':
      case 'wellness':
      case 'salon':
      case 'beauty':
      case 'fitness':
      case 'gym':
        return Icons.spa_rounded;
      case 'account_balance':
      case 'bank':
      case 'loans':
      case 'loan':
      case 'emi':
      case 'banking':
      case 'debt':
      case 'tax':
      case 'taxes':
        return Icons.account_balance_rounded;
      case 'shield':
      case 'insurance':
      case 'security':
      case 'policy':
        return Icons.shield_rounded;
      case 'medical_services':
      case 'health':
      case 'medical':
      case 'medicine':
      case 'doctor':
      case 'hospital':
      case 'pharmacy':
      case 'healthcare':
        return Icons.medical_services_rounded;
      case 'more_horiz':
      case 'other':
      case 'others':
      case 'misc':
      case 'miscellaneous':
        return Icons.more_horiz_rounded;
      case 'account_balance_wallet':
      case 'salary':
      case 'wallet':
      case 'income':
      case 'wage':
      case 'wages':
      case 'paycheck':
        return Icons.account_balance_wallet_rounded;
      case 'stars':
      case 'star':
      case 'bonus':
      case 'reward':
      case 'rewards':
      case 'incentive':
        return Icons.stars_rounded;
      case 'percent':
      case 'interest':
      case 'dividend':
      case 'dividends':
        return Icons.percent_rounded;
      case 'laptop_mac':
      case 'freelance':
      case 'work':
      case 'job':
      case 'tech':
      case 'office':
        return Icons.laptop_mac_rounded;
      case 'store':
      case 'business':
      case 'shop':
      case 'sales':
        return Icons.store_rounded;
      case 'trending_up':
      case 'investment':
      case 'investments':
      case 'invest':
      case 'stocks':
      case 'stock':
      case 'mutual funds':
      case 'crypto':
      case 'trading':
        return Icons.trending_up_rounded;
      case 'card_giftcard':
      case 'gift':
      case 'gifts':
      case 'present':
      case 'donation':
      case 'charity':
        return Icons.card_giftcard_rounded;
      case 'attach_money':
      case 'money':
      case 'cash':
        return Icons.attach_money_rounded;
      default:
        return null;
    }
  }

  static IconData? _matchNameHeuristics(String name) {
    if (name.contains('food') ||
        name.contains('dine') ||
        name.contains('dining') ||
        name.contains('eat') ||
        name.contains('restaurant') ||
        name.contains('cafe') ||
        name.contains('coffee') ||
        name.contains('snack') ||
        name.contains('lunch') ||
        name.contains('dinner') ||
        name.contains('breakfast')) {
      return Icons.restaurant;
    }
    if (name.contains('rent') ||
        name.contains('house') ||
        name.contains('home') ||
        name.contains('flat') ||
        name.contains('apartment') ||
        name.contains('mortgage')) {
      return Icons.home_rounded;
    }
    if (name.contains('grocer') ||
        name.contains('supermarket') ||
        name.contains('vegetable') ||
        name.contains('fruit')) {
      return Icons.shopping_cart_rounded;
    }
    if (name.contains('shopping') ||
        name.contains('cloth') ||
        name.contains('apparel') ||
        name.contains('fashion')) {
      return Icons.shopping_bag_rounded;
    }
    if (name.contains('transport') ||
        name.contains('car') ||
        name.contains('fuel') ||
        name.contains('petrol') ||
        name.contains('diesel') ||
        name.contains('gas') ||
        name.contains('commute') ||
        name.contains('taxi') ||
        name.contains('cab') ||
        name.contains('uber') ||
        name.contains('ola') ||
        name.contains('bus') ||
        name.contains('train') ||
        name.contains('metro') ||
        name.contains('auto') ||
        name.contains('vehicle')) {
      return Icons.directions_car_rounded;
    }
    if (name.contains('bill') ||
        name.contains('electric') ||
        name.contains('water') ||
        name.contains('utility') ||
        name.contains('utilities') ||
        name.contains('internet') ||
        name.contains('wifi') ||
        name.contains('broadband') ||
        name.contains('recharge') ||
        name.contains('phone') ||
        name.contains('mobile') ||
        name.contains('dth')) {
      return Icons.receipt_long_rounded;
    }
    if (name.contains('health') ||
        name.contains('medic') ||
        name.contains('doctor') ||
        name.contains('hospital') ||
        name.contains('pharmacy') ||
        name.contains('clinic')) {
      return Icons.medical_services_rounded;
    }
    if (name.contains('entertain') ||
        name.contains('movie') ||
        name.contains('cinema') ||
        name.contains('theatre') ||
        name.contains('netflix') ||
        name.contains('film')) {
      return Icons.movie_rounded;
    }
    if (name.contains('game') ||
        name.contains('gaming') ||
        name.contains('esport')) {
      return Icons.sports_esports_rounded;
    }
    if (name.contains('school') ||
        name.contains('educat') ||
        name.contains('college') ||
        name.contains('course') ||
        name.contains('tuition') ||
        name.contains('study') ||
        name.contains('book')) {
      return Icons.school_rounded;
    }
    if (name.contains('travel') ||
        name.contains('flight') ||
        name.contains('plane') ||
        name.contains('trip') ||
        name.contains('tour') ||
        name.contains('hotel') ||
        name.contains('holiday') ||
        name.contains('vacation')) {
      return Icons.flight_rounded;
    }
    if (name.contains('spa') ||
        name.contains('salon') ||
        name.contains('beauty') ||
        name.contains('wellness') ||
        name.contains('personal care') ||
        name.contains('hair') ||
        name.contains('gym') ||
        name.contains('fitness')) {
      return Icons.spa_rounded;
    }
    if (name.contains('bank') ||
        name.contains('loan') ||
        name.contains('emi') ||
        name.contains('debt') ||
        name.contains('tax')) {
      return Icons.account_balance_rounded;
    }
    if (name.contains('insur') ||
        name.contains('shield') ||
        name.contains('policy')) {
      return Icons.shield_rounded;
    }
    if (name.contains('gift') ||
        name.contains('present') ||
        name.contains('charity') ||
        name.contains('donation')) {
      return Icons.card_giftcard_rounded;
    }
    if (name.contains('salary') ||
        name.contains('paycheck') ||
        name.contains('wage') ||
        name.contains('wallet')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (name.contains('bonus') ||
        name.contains('reward') ||
        name.contains('award') ||
        name.contains('star')) {
      return Icons.stars_rounded;
    }
    if (name.contains('invest') ||
        name.contains('stock') ||
        name.contains('crypto') ||
        name.contains('share') ||
        name.contains('mutual') ||
        name.contains('trading')) {
      return Icons.trending_up_rounded;
    }
    if (name.contains('freelance') ||
        name.contains('work') ||
        name.contains('laptop') ||
        name.contains('office') ||
        name.contains('client')) {
      return Icons.laptop_mac_rounded;
    }
    if (name.contains('business') ||
        name.contains('store') ||
        name.contains('shop')) {
      return Icons.store_rounded;
    }
    if (name.contains('other') || name.contains('misc')) {
      return Icons.more_horiz_rounded;
    }
    return null;
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

import 'package:kharch_mate/database/database_constants.dart';

class UserProfile {
  final int? id;
  final String name;
  final String? email;
  final String currencyCode;
  final String currencySymbol;
  final bool isDarkMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    this.id,
    required this.name,
    this.email,
    this.currencyCode = 'INR',
    this.currencySymbol = '₹',
    this.isDarkMode = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? currencyCode,
    String? currencySymbol,
    bool? isDarkMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.colUserId: id,
      DatabaseConstants.colUserName: name,
      DatabaseConstants.colUserEmail: email,
      DatabaseConstants.colUserCurrencyCode: currencyCode,
      DatabaseConstants.colUserCurrencySymbol: currencySymbol,
      DatabaseConstants.colUserIsDarkMode: isDarkMode ? 1 : 0,
      DatabaseConstants.colUserCreatedAt: createdAt.toIso8601String(),
      DatabaseConstants.colUserUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map[DatabaseConstants.colUserId] as int?,
      name: map[DatabaseConstants.colUserName] as String? ?? '',
      email: map[DatabaseConstants.colUserEmail] as String?,
      currencyCode:
          map[DatabaseConstants.colUserCurrencyCode] as String? ?? 'INR',
      currencySymbol:
          map[DatabaseConstants.colUserCurrencySymbol] as String? ?? '₹',
      isDarkMode: (map[DatabaseConstants.colUserIsDarkMode] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(
            map[DatabaseConstants.colUserCreatedAt] as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            map[DatabaseConstants.colUserUpdatedAt] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

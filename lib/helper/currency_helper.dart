import 'package:intl/intl.dart';

class CurrencyModel {
  final String code;
  final String symbol;
  final String name;

  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class CurrencyHelper {
  static const List<CurrencyModel> supportedCurrencies = [
    CurrencyModel(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    CurrencyModel(code: 'USD', symbol: '\$', name: 'US Dollar'),
    CurrencyModel(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyModel(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyModel(code: 'AED', symbol: 'AED', name: 'UAE Dirham'),
    CurrencyModel(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar'),
    CurrencyModel(code: 'AUD', symbol: 'AU\$', name: 'Australian Dollar'),
    CurrencyModel(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  ];

  /// Normalizes legacy or non-standard symbols to clean standards
  static String normalizeSymbol(String? symbol, {String? code}) {
    if (symbol == null || symbol.trim().isEmpty) {
      if (code != null) {
        return symbolForCode(code);
      }
      return '₹';
    }
    final trimmed = symbol.trim();
    if (trimmed == 'د.إ' || trimmed.toLowerCase() == 'aed' || code == 'AED') {
      return 'AED';
    }
    if (trimmed == 'C\$' || code == 'CAD') {
      return 'CA\$';
    }
    if (trimmed == 'A\$' || code == 'AUD') {
      return 'AU\$';
    }
    return trimmed;
  }

  /// Returns the standard symbol for a given currency code
  static String symbolForCode(String code) {
    for (final c in supportedCurrencies) {
      if (c.code.toUpperCase() == code.toUpperCase()) {
        return c.symbol;
      }
    }
    return '₹';
  }

  /// Formats amount with standard spacing and grouping.
  /// - Single character symbols ($100, ₹100, €100, £100, ¥100) are prefixed without space.
  /// - Multi-character symbols (AED 100, CA$ 100, AU$ 100) include a clean space.
  /// - INR uses Indian grouping (#,##,###), while others use international grouping (#,##0).
  static String formatAmount(
    double amount, {
    String symbol = '₹',
    bool showSign = false,
    bool isIncome = false,
  }) {
    final cleanSymbol = normalizeSymbol(symbol);
    final isIndian = cleanSymbol == '₹' || cleanSymbol == 'INR';
    final hasDecimal = (amount % 1) != 0;

    final pattern = isIndian
        ? (hasDecimal ? '#,##,###.##' : '#,##,###')
        : (hasDecimal ? '#,##0.##' : '#,##0');

    final formattedNumber = NumberFormat(pattern).format(amount.abs());

    // Add space if symbol has letters or length > 1
    final needsSpace = cleanSymbol.length > 1 || RegExp(r'[A-Za-z]').hasMatch(cleanSymbol);
    final separator = needsSpace ? ' ' : '';

    if (showSign) {
      final sign = isIncome ? '+ ' : '- ';
      return '$sign$cleanSymbol$separator$formattedNumber';
    } else {
      final sign = amount < 0 ? '-' : '';
      return '$sign$cleanSymbol$separator$formattedNumber';
    }
  }
}

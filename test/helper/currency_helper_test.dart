import 'package:flutter_test/flutter_test.dart';
import 'package:kharch_mate/helper/currency_helper.dart';

void main() {
  group('CurrencyHelper tests', () {
    test('normalizeSymbol correctly converts legacy/RTL symbols to standard', () {
      expect(CurrencyHelper.normalizeSymbol('د.إ'), equals('AED'));
      expect(CurrencyHelper.normalizeSymbol('C\$'), equals('CA\$'));
      expect(CurrencyHelper.normalizeSymbol('A\$'), equals('AU\$'));
      expect(CurrencyHelper.normalizeSymbol(null, code: 'AED'), equals('AED'));
      expect(CurrencyHelper.normalizeSymbol(null, code: 'USD'), equals('\$'));
      expect(CurrencyHelper.normalizeSymbol('₹'), equals('₹'));
    });

    test('formatAmount handles single-character symbols without space', () {
      expect(CurrencyHelper.formatAmount(0, symbol: '₹'), equals('₹0'));
      expect(CurrencyHelper.formatAmount(100, symbol: '\$'), equals('\$100'));
      expect(CurrencyHelper.formatAmount(100, symbol: '€'), equals('€100'));
      expect(CurrencyHelper.formatAmount(100, symbol: '£'), equals('£100'));
      expect(CurrencyHelper.formatAmount(100, symbol: '¥'), equals('¥100'));
    });

    test('formatAmount handles multi-character symbols with space', () {
      expect(CurrencyHelper.formatAmount(0, symbol: 'AED'), equals('AED 0'));
      expect(CurrencyHelper.formatAmount(0, symbol: 'د.إ'), equals('AED 0'));
      expect(CurrencyHelper.formatAmount(1500, symbol: 'CA\$'), equals('CA\$ 1,500'));
      expect(CurrencyHelper.formatAmount(1500, symbol: 'C\$'), equals('CA\$ 1,500'));
      expect(CurrencyHelper.formatAmount(1500, symbol: 'AU\$'), equals('AU\$ 1,500'));
      expect(CurrencyHelper.formatAmount(1500, symbol: 'A\$'), equals('AU\$ 1,500'));
    });

    test('formatAmount uses Indian grouping for INR and standard 3-digit grouping for others', () {
      expect(CurrencyHelper.formatAmount(100000, symbol: '₹'), equals('₹1,00,000'));
      expect(CurrencyHelper.formatAmount(100000, symbol: '\$'), equals('\$100,000'));
      expect(CurrencyHelper.formatAmount(100000, symbol: 'AED'), equals('AED 100,000'));
      expect(CurrencyHelper.formatAmount(100000, symbol: 'CA\$'), equals('CA\$ 100,000'));
    });

    test('formatAmount handles signed amounts correctly', () {
      expect(
        CurrencyHelper.formatAmount(500, symbol: 'AED', showSign: true, isIncome: true),
        equals('+ AED 500'),
      );
      expect(
        CurrencyHelper.formatAmount(500, symbol: 'AED', showSign: true, isIncome: false),
        equals('- AED 500'),
      );
      expect(
        CurrencyHelper.formatAmount(500, symbol: '\$', showSign: true, isIncome: true),
        equals('+ \$500'),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:trolly/models/app_preferences.dart';
import 'package:trolly/services/currency_service.dart';

void main() {
  test('converts PHP centavos to USD cents using the prototype rate', () {
    expect(
      CurrencyService.convertMinorUnits(
        5800,
        TrollyCurrency.php,
        TrollyCurrency.usd,
      ),
      100,
    );
  });

  test('converts USD cents to PHP centavos using the prototype rate', () {
    expect(
      CurrencyService.convertMinorUnits(
        100,
        TrollyCurrency.usd,
        TrollyCurrency.php,
      ),
      5800,
    );
  });

  test('converts major currency units through rounded minor units', () {
    expect(
      CurrencyService.convertMajorUnits(
        22,
        TrollyCurrency.php,
        TrollyCurrency.usd,
      ),
      0.38,
    );
    expect(
      CurrencyService.convertMajorUnits(
        44,
        TrollyCurrency.php,
        TrollyCurrency.usd,
      ),
      0.76,
    );
  });

  test('formats supported currencies with grouping and decimals', () {
    expect(
      CurrencyService.formatMinorUnits(1400000, TrollyCurrency.php),
      '₱14,000',
    );
    expect(
      CurrencyService.formatMinorUnits(12345, TrollyCurrency.usd),
      r'$123.45',
    );
  });
}

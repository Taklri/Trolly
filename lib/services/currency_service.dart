import '../models/app_preferences.dart';

class CurrencyService {
  const CurrencyService._();

  // Prototype conversion rate kept in one place for future live-rate support.
  static const int phpCentavosPerUsd = 5800;

  static int convertMinorUnits(
    int amount,
    TrollyCurrency from,
    TrollyCurrency to,
  ) {
    if (from == to) return amount;

    if (from == TrollyCurrency.php && to == TrollyCurrency.usd) {
      return (amount * 100 / phpCentavosPerUsd).round();
    }

    return (amount * phpCentavosPerUsd / 100).round();
  }

  static String formatMinorUnits(int amount, TrollyCurrency currency) {
    final absoluteAmount = amount.abs();
    final majorUnits = absoluteAmount ~/ 100;
    final minorUnits = absoluteAmount % 100;
    final groupedMajorUnits = majorUnits.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    final sign = amount < 0 ? '-' : '';
    final formattedMajor = '$sign${currency.symbol}$groupedMajorUnits';

    if (amount == 0 || minorUnits != 0) {
      return '$formattedMajor.${minorUnits.toString().padLeft(2, '0')}';
    }

    return formattedMajor;
  }
}

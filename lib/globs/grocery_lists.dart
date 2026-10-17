import '../models/app_preferences.dart';
import '../services/currency_service.dart';

class GroceryListData {
  static List<Map<String, dynamic>> lists = [];
  static int nextId = 1;

  static TrollyCurrency currencyFor(Map<String, dynamic> groceryList) {
    dynamic code = groceryList['currencyCode'];
    return trollyCurrencyFromCode(code is String ? code : null);
  }

  static String currencyMoney(double amount, Map<String, dynamic> groceryList) {
    TrollyCurrency currency = currencyFor(groceryList);
    if (amount == 0) return '${currency.symbol}0';

    return CurrencyService.formatMinorUnits((amount * 100).round(), currency);
  }

  static void reset() {
    lists = [];
    nextId = 1;
  }
}

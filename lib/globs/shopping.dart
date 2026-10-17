import '../models/app_preferences.dart';
import '../services/user_preferences.dart';

class ShoppingData {
  static bool hasBudget = false;
  static double startingBudget = 0;
  static TrollyCurrency currency = TrollyCurrency.php;
  static bool isGroceryListShopping = false;
  static String groceryListName = '';

  static List<Map<String, dynamic>> currentProducts = [];
  static List<Map<String, dynamic>> shoppingHistory = [];

  static void startShopping({required bool withBudget, double budget = 0}) {
    hasBudget = withBudget;
    startingBudget = budget;
    isGroceryListShopping = false;
    groceryListName = '';
    currentProducts = [];
  }

  static Future<void> loadCurrency() async {
    currency = await const UserPreferences().readCurrency();
  }

  static void startGroceryListShopping({
    required String listName,
    required List<Map<String, dynamic>> products,
  }) {
    hasBudget = false;
    startingBudget = 0;
    isGroceryListShopping = true;
    groceryListName = listName;
    currentProducts = [];

    for (int i = 0; i < products.length; i++) {
      Map<String, dynamic> product = Map<String, dynamic>.from(products[i]);
      product['checked'] = false;
      currentProducts.add(product);
    }
  }

  static double totalSpending() {
    double total = 0;

    for (int i = 0; i < currentProducts.length; i++) {
      total += (currentProducts[i]['totalAmount'] as num).toDouble();
    }

    return total;
  }

  static double budgetLeft() {
    return startingBudget - totalSpending();
  }

  static double checkedTotal() {
    double total = 0;

    for (int i = 0; i < currentProducts.length; i++) {
      if (currentProducts[i]['checked'] == true) {
        total += (currentProducts[i]['totalAmount'] as num).toDouble();
      }
    }

    return total;
  }

  static List<Map<String, dynamic>> productsForSummary() {
    List<Map<String, dynamic>> products = [];

    for (int i = 0; i < currentProducts.length; i++) {
      if (isGroceryListShopping && currentProducts[i]['checked'] != true) {
        continue;
      }

      products.add(Map<String, dynamic>.from(currentProducts[i]));
    }

    return products;
  }

  static double amountForSummary() {
    return isGroceryListShopping ? checkedTotal() : totalSpending();
  }

  static void clearShoppingSession() {
    currentProducts = [];
    hasBudget = false;
    startingBudget = 0;
    isGroceryListShopping = false;
    groceryListName = '';
  }

  static bool productNameExists(String name, {int? exceptIndex}) {
    String newName = name.trim().toLowerCase();

    for (int i = 0; i < currentProducts.length; i++) {
      if (exceptIndex != null && i == exceptIndex) continue;

      String oldName = currentProducts[i]['productName']
          .toString()
          .trim()
          .toLowerCase();

      if (newName == oldName) return true;
    }

    return false;
  }

  static String money(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }

    return amount.toStringAsFixed(2);
  }

  static String currencyMoney(double amount) {
    return '${currency.symbol}${money(amount)}';
  }

  static void saveHistory() {
    List<Map<String, dynamic>> products = productsForSummary();

    shoppingHistory.add({
      'hasBudget': hasBudget,
      'startingBudget': startingBudget,
      'products': products,
      'totalAmount': amountForSummary(),
      'budgetLeft': hasBudget ? budgetLeft() : null,
      'title': isGroceryListShopping ? groceryListName : 'On the go shopping',
    });
  }
}

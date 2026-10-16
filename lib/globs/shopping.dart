class ShoppingData {
  static bool hasBudget = false;
  static double startingBudget = 0;

  static List<Map<String, dynamic>> currentProducts = [];
  static List<Map<String, dynamic>> shoppingHistory = [];

  static void startShopping({required bool withBudget, double budget = 0}) {
    hasBudget = withBudget;
    startingBudget = budget;
    currentProducts = [];
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

  static void saveHistory() {
    List<Map<String, dynamic>> products = [];

    for (int i = 0; i < currentProducts.length; i++) {
      products.add(Map<String, dynamic>.from(currentProducts[i]));
    }

    shoppingHistory.add({
      'hasBudget': hasBudget,
      'startingBudget': startingBudget,
      'products': products,
      'totalAmount': totalSpending(),
      'budgetLeft': hasBudget ? budgetLeft() : null,
    });
  }
}

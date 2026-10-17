import 'app_preferences.dart';

class ShoppingHistoryEntry {
  const ShoppingHistoryEntry({
    required this.id,
    required this.completedAt,
    required this.title,
    required this.totalCentavos,
    this.currencyCode = 'PHP',
    this.products,
    this.hasBudget,
    this.startingBudgetCentavos,
    this.budgetLeftCentavos,
  });

  final String id;
  final DateTime completedAt;
  final String title;
  final int totalCentavos;
  final String currencyCode;

  TrollyCurrency get currency => trollyCurrencyFromCode(currencyCode);
  final List<Map<String, dynamic>>? products;
  final bool? hasBudget;
  final int? startingBudgetCentavos;
  final int? budgetLeftCentavos;

  bool get hasFullDetails => products != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completedAt': completedAt.toIso8601String(),
      'title': title,
      'totalCentavos': totalCentavos,
      'currencyCode': currency.code,
      'products': products,
      'hasBudget': hasBudget,
      'startingBudgetCentavos': startingBudgetCentavos,
      'budgetLeftCentavos': budgetLeftCentavos,
    };
  }

  factory ShoppingHistoryEntry.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final completedAt = json['completedAt'];
    final title = json['title'];
    final totalCentavos = json['totalCentavos'];
    final currencyCode = json['currencyCode'];
    final savedProducts = json['products'];
    final savedHasBudget = json['hasBudget'];
    final savedStartingBudget = json['startingBudgetCentavos'];
    final savedBudgetLeft = json['budgetLeftCentavos'];

    if (id is! String ||
        completedAt is! String ||
        title is! String ||
        totalCentavos is! num) {
      throw const FormatException('Invalid shopping history entry.');
    }

    List<Map<String, dynamic>>? products;
    if (savedProducts is List) {
      products = [];
      for (int i = 0; i < savedProducts.length; i++) {
        if (savedProducts[i] is Map<String, dynamic>) {
          products.add(Map<String, dynamic>.from(savedProducts[i]));
        }
      }
    }

    return ShoppingHistoryEntry(
      id: id,
      completedAt: DateTime.parse(completedAt),
      title: title,
      totalCentavos: totalCentavos.toInt(),
      currencyCode: trollyCurrencyFromCode(
        currencyCode is String ? currencyCode : null,
      ).code,
      products: products,
      hasBudget: savedHasBudget is bool ? savedHasBudget : null,
      startingBudgetCentavos: savedStartingBudget is num
          ? savedStartingBudget.toInt()
          : null,
      budgetLeftCentavos: savedBudgetLeft is num
          ? savedBudgetLeft.toInt()
          : null,
    );
  }
}

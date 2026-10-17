import 'package:flutter/material.dart';

import '../globs/shopping.dart';
import '../models/app_preferences.dart';
import '../models/shopping_history_entry.dart';
import '../services/shopping_history_repository.dart';
import '../services/user_preferences.dart';

class ShoppingSummaryScreen extends StatefulWidget {
  const ShoppingSummaryScreen({
    super.key,
    this.repository = const ShoppingHistoryRepository(),
    this.userPreferences = const UserPreferences(),
  });

  final ShoppingHistoryRepository repository;
  final UserPreferences userPreferences;

  @override
  State<ShoppingSummaryScreen> createState() => _ShoppingSummaryScreenState();
}

class _ShoppingSummaryScreenState extends State<ShoppingSummaryScreen> {
  TrollyCurrency _currency = TrollyCurrency.php;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final currency = await widget.userPreferences.readCurrency();
    if (!mounted) return;
    setState(() => _currency = currency);
    ShoppingData.currency = currency;
  }

  Future<void> finishShopping() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    final total = ShoppingData.amountForSummary();
    final products = ShoppingData.productsForSummary();
    final savedProducts = products
        .map(
          (product) => <String, dynamic>{
            'productName': product['productName'],
            'productPriceCentavos':
                ((product['productPrice'] as num).toDouble() * 100).round(),
            'quantity': product['quantity'],
            'totalCentavos': ((product['totalAmount'] as num).toDouble() * 100)
                .round(),
          },
        )
        .toList();

    ShoppingData.saveHistory();
    final completedAt = DateTime.now();
    await widget.repository.addEntry(
      ShoppingHistoryEntry(
        id: completedAt.microsecondsSinceEpoch.toString(),
        completedAt: completedAt,
        title: ShoppingData.isGroceryListShopping
            ? ShoppingData.groceryListName
            : 'On the go shopping',
        totalCentavos: (total * 100).round(),
        currencyCode: _currency.code,
        products: savedProducts,
        hasBudget: ShoppingData.hasBudget,
        startingBudgetCentavos: ShoppingData.hasBudget
            ? (ShoppingData.startingBudget * 100).round()
            : null,
        budgetLeftCentavos: ShoppingData.hasBudget
            ? (ShoppingData.budgetLeft() * 100).round()
            : null,
      ),
    );

    ShoppingData.clearShoppingSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  Widget productRow(Map<String, dynamic> product) {
    final total = (product['totalAmount'] as num).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            product['productName'].toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider()),
          const SizedBox(width: 10),
          Text(
            ShoppingData.currencyMoney(total),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget totalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = ShoppingData.amountForSummary();
    final products = ShoppingData.productsForSummary();
    final groceryMode = ShoppingData.isGroceryListShopping;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Colors.grey[600],
                ),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: Text(
                  groceryMode ? 'Back to List' : 'Back to Shopping',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const Text(
                'Here’s your',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const Text(
                'grocery summary',
                style: TextStyle(
                  fontSize: 30,
                  height: 0.95,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF13AD58),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) => productRow(products[index]),
                ),
              ),
              const Divider(),
              totalRow('Total Amount:', ShoppingData.currencyMoney(total)),
              if (ShoppingData.hasBudget)
                totalRow(
                  'Budget Left:',
                  ShoppingData.currencyMoney(ShoppingData.budgetLeft()),
                ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFinishing ? null : finishShopping,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13AD58),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Finish Shopping',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

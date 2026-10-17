import 'package:flutter/material.dart';
import '../globs/shopping.dart';
import '../models/shopping_history_entry.dart';
import '../services/shopping_history_repository.dart';

class ShoppingSummaryScreen extends StatelessWidget {
  const ShoppingSummaryScreen({
    super.key,
    this.repository = const ShoppingHistoryRepository(),
  });

  final ShoppingHistoryRepository repository;

  void cancelSummary(BuildContext context) {
    Navigator.pop(context);
  }

  void finishShopping(BuildContext context) {
    double total = ShoppingData.amountForSummary();
    DateTime completedAt = DateTime.now();
    List<Map<String, dynamic>> products = ShoppingData.productsForSummary();
    List<Map<String, dynamic>> savedProducts = [];

    for (int i = 0; i < products.length; i++) {
      Map<String, dynamic> product = products[i];
      savedProducts.add({
        'productName': product['productName'],
        'productPriceCentavos':
            ((product['productPrice'] as num).toDouble() * 100).round(),
        'quantity': product['quantity'],
        'totalCentavos': ((product['totalAmount'] as num).toDouble() * 100)
            .round(),
      });
    }

    ShoppingData.saveHistory();
    repository
        .addEntry(
          ShoppingHistoryEntry(
            id: completedAt.microsecondsSinceEpoch.toString(),
            completedAt: completedAt,
            title: ShoppingData.isGroceryListShopping
                ? ShoppingData.groceryListName
                : 'On the go shopping',
            totalCentavos: (total * 100).round(),
            products: savedProducts,
            hasBudget: ShoppingData.hasBudget,
            startingBudgetCentavos: ShoppingData.hasBudget
                ? (ShoppingData.startingBudget * 100).round()
                : null,
            budgetLeftCentavos: ShoppingData.hasBudget
                ? (ShoppingData.budgetLeft() * 100).round()
                : null,
          ),
        )
        .then((_) {
          if (context.mounted == false) return;

          ShoppingData.clearShoppingSession();
          Navigator.pushReplacementNamed(context, '/home');
        });
  }

  Widget productRow(Map<String, dynamic> product) {
    double total = (product['totalAmount'] as num).toDouble();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            product['productName'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 10),
          Expanded(child: Divider()),
          SizedBox(width: 10),
          Text('₱${ShoppingData.money(total)}', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget totalRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = ShoppingData.amountForSummary();
    List<Map<String, dynamic>> products = ShoppingData.productsForSummary();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  cancelSummary(context);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Colors.grey[600],
                ),
                icon: Icon(Icons.arrow_back, size: 20),
                label: Text(
                  ShoppingData.isGroceryListShopping
                      ? 'Back to List'
                      : 'Back to Shopping',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Text(
                'Here’s your',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              Text(
                'grocery summary',
                style: TextStyle(
                  fontSize: 30,
                  height: 0.95,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF13AD58),
                ),
              ),
              SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return productRow(products[index]);
                  },
                ),
              ),
              Divider(),
              totalRow('Total Amount:', '₱${ShoppingData.money(total)}'),
              if (ShoppingData.hasBudget)
                totalRow(
                  'Budget Left:',
                  '₱${ShoppingData.money(ShoppingData.budgetLeft())}',
                ),
              SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    finishShopping(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF13AD58),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
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

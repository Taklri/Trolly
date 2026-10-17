import 'package:flutter/material.dart';

import '../globs/shopping.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => ShoppingPage();
}

class ShoppingPage extends State<ShoppingScreen> {
  String err = '';

  void deleteProduct(int index) {
    setState(() {
      ShoppingData.currentProducts.removeAt(index);
    });
  }

  void confirmDelete(int index) {
    final productName = ShoppingData.currentProducts[index]['productName']
        .toString();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Product?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text('Are you sure you want to delete $productName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteProduct(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void editProduct(int index) {
    Navigator.pushNamed(context, '/edit-product', arguments: index);
  }

  void cancelShopping() {
    if (ShoppingData.isGroceryListShopping) ShoppingData.clearShoppingSession();
    Navigator.pop(context);
  }

  void finishShopping() {
    if (ShoppingData.isGroceryListShopping &&
        ShoppingData.checkedTotal() == 0) {
      setState(() => err = 'Check at least one product before finishing.');
    } else if (ShoppingData.currentProducts.isEmpty) {
      setState(() => err = 'Add at least one product before finishing.');
    } else {
      Navigator.pushNamed(context, '/shopping-summary');
    }
  }

  Widget productCard(int index) {
    final product = ShoppingData.currentProducts[index];
    final total = (product['totalAmount'] as num).toDouble();
    final checked = product['checked'] == true;
    final groceryMode = ShoppingData.isGroceryListShopping;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      constraints: const BoxConstraints(minHeight: 96),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD3D3D3)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            if (groceryMode)
              Checkbox(
                key: Key('grocery-product-checkbox-$index'),
                value: checked,
                onChanged: (value) => setState(() {
                  product['checked'] = value == true;
                  err = '';
                }),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['productName'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${groceryMode && checked ? '+' : '-'} ${ShoppingData.currencyMoney(total)}',
                    style: TextStyle(
                      color: groceryMode && checked
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFFF3B30),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => editProduct(index),
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(),
              iconSize: 24,
              icon: const Icon(Icons.edit, color: Color(0xFFFF9800)),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => confirmDelete(index),
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(),
              iconSize: 23,
              icon: const Icon(Icons.delete, color: Color(0xFFFF3B30)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groceryMode = ShoppingData.isGroceryListShopping;
    final total = groceryMode
        ? ShoppingData.checkedTotal()
        : ShoppingData.totalSpending();
    final budgetLeft = ShoppingData.budgetLeft();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && groceryMode) ShoppingData.clearShoppingSession();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: cancelShopping,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Colors.grey[600],
                  ),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  label: Text(
                    groceryMode ? 'Back to List' : 'Back to Method',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  groceryMode ? ShoppingData.groceryListName : 'Shop Well!',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (groceryMode)
                  Text(
                    '${ShoppingData.currentProducts.length} ${ShoppingData.currentProducts.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                const SizedBox(height: 6),
                Text(
                  groceryMode
                      ? 'Current Amount'
                      : ShoppingData.hasBudget
                      ? 'Current Budget'
                      : 'Total Spending',
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
                const Divider(height: 8),
                Text(
                  groceryMode
                      ? ShoppingData.currencyMoney(total)
                      : ShoppingData.hasBudget
                      ? ShoppingData.currencyMoney(budgetLeft)
                      : ShoppingData.currencyMoney(total),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color:
                        !groceryMode &&
                            ShoppingData.hasBudget &&
                            budgetLeft <= 0
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
                if (!groceryMode && ShoppingData.hasBudget && budgetLeft <= 0)
                  const Text(
                    'Your budget has been emptied. Review your shopping before finishing.',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                if (err.isNotEmpty)
                  Text(
                    err,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: ShoppingData.currentProducts.isEmpty
                      ? Center(
                          child: Image.asset(
                            'assets/images/No Products.png',
                            width: 240,
                          ),
                        )
                      : ListView.builder(
                          itemCount: ShoppingData.currentProducts.length,
                          itemBuilder: (context, index) => productCard(index),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: cancelShopping,
                        iconSize: 29,
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFFFA000),
                        ),
                      ),
                      if (!groceryMode)
                        FloatingActionButton(
                          backgroundColor: const Color(0xFFFFA000),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/add-product'),
                          child: const Icon(Icons.add, size: 30),
                        ),
                      IconButton(
                        onPressed: finishShopping,
                        iconSize: 29,
                        icon: const Icon(
                          Icons.flag_outlined,
                          color: Color(0xFFFFA000),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

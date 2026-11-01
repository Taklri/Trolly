import 'package:flutter/material.dart';

import '../globs/grocery_lists.dart';
import '../globs/shopping.dart';
import '../services/currency_service.dart';

const _trollyGreen = Color(0xFF16A34A);
const _trollyText = Color(0xFF171717);
const _trollySecondaryText = Color(0xFF616161);
const _trollyBorder = Color(0xFFD8D8D8);

class GroceryListSelectionScreen extends StatefulWidget {
  const GroceryListSelectionScreen({super.key});

  @override
  State<GroceryListSelectionScreen> createState() => GroceryListSelectionPage();
}

class GroceryListSelectionPage extends State<GroceryListSelectionScreen> {
  Future<void> openCreateList() async {
    await Navigator.pushNamed(context, '/create-list');
    if (mounted) setState(() {});
  }

  Future<void> startShopping(int index) async {
    Map<String, dynamic> groceryList = GroceryListData.lists[index];
    List<Map<String, dynamic>> products = [];
    dynamic savedProducts = groceryList['products'];
    final sourceCurrency = GroceryListData.currencyFor(groceryList);

    await ShoppingData.loadCurrency();
    if (!mounted) return;

    final targetCurrency = ShoppingData.currency;

    if (savedProducts is List) {
      for (int i = 0; i < savedProducts.length; i++) {
        if (savedProducts[i] is Map<String, dynamic>) {
          Map<String, dynamic> product = Map<String, dynamic>.from(
            savedProducts[i],
          );

          if (product['productPrice'] is num) {
            product['productPrice'] = CurrencyService.convertMajorUnits(
              (product['productPrice'] as num).toDouble(),
              sourceCurrency,
              targetCurrency,
            );
          }
          if (product['totalAmount'] is num) {
            product['totalAmount'] = CurrencyService.convertMajorUnits(
              (product['totalAmount'] as num).toDouble(),
              sourceCurrency,
              targetCurrency,
            );
          }

          products.add(product);
        }
      }
    }

    ShoppingData.startGroceryListShopping(
      listName: groceryList['name'].toString(),
      products: products,
    );
    Navigator.pushNamed(context, '/shopping');
  }

  double listTotal(Map<String, dynamic> groceryList) {
    double total = 0;
    dynamic products = groceryList['products'];

    if (products is List) {
      for (int i = 0; i < products.length; i++) {
        if (products[i] is Map<String, dynamic>) {
          total += (products[i]['totalAmount'] as num).toDouble();
        }
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    double pagePadding = MediaQuery.sizeOf(context).width < 360 ? 16 : 24;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pagePadding, 24, pagePadding, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('grocery-lists-back'),
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: _trollySecondaryText,
                      ),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back to Method'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your Lists',
                    style: TextStyle(
                      color: _trollyText,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${GroceryListData.lists.length} ${GroceryListData.lists.length == 1 ? 'grocery list' : 'grocery lists'}',
                    style: const TextStyle(
                      color: _trollySecondaryText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GroceryListData.lists.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            itemCount: GroceryListData.lists.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildListCard(index);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/No Grocery List.png',
              width: 220,
              semanticLabel: 'No grocery lists',
            ),
            const SizedBox(height: 12),
            const Text(
              'No grocery lists yet',
              style: TextStyle(
                color: _trollyText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create a list before shopping this way.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _trollySecondaryText, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('grocery-lists-create'),
              onPressed: openCreateList,
              style: ElevatedButton.styleFrom(
                backgroundColor: _trollyGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Create List'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(int index) {
    Map<String, dynamic> groceryList = GroceryListData.lists[index];
    List<dynamic> products = groceryList['products'] is List
        ? groceryList['products'] as List<dynamic>
        : [];

    return OutlinedButton(
      key: Key('grocery-list-select-$index'),
      onPressed: () => startShopping(index),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(16),
        foregroundColor: _trollyText,
        side: const BorderSide(color: _trollyBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groceryList['name'].toString(),
                  style: const TextStyle(
                    color: _trollyText,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${products.length} ${products.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    color: _trollySecondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total',
                style: TextStyle(color: _trollySecondaryText, fontSize: 11),
              ),
              Text(
                GroceryListData.currencyMoney(
                  listTotal(groceryList),
                  groceryList,
                ),
                style: const TextStyle(
                  color: _trollyText,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

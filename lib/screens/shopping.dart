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

  void editProduct(int index) {
    Navigator.pushReplacementNamed(context, '/edit-product', arguments: index);
  }

  void cancelShopping() {
    Navigator.pop(context);
  }

  void finishShopping() {
    if (ShoppingData.currentProducts.isEmpty) {
      setState(() {
        err = 'Add at least one product before finishing.';
      });
    } else {
      Navigator.pushNamed(context, '/shopping-summary');
    }
  }

  Widget productCard(int index) {
    Map<String, dynamic> product = ShoppingData.currentProducts[index];
    double total = (product['totalAmount'] as num).toDouble();

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      constraints: BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFD3D3D3)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['productName'],
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  Text(
                    '- ₱${ShoppingData.money(total)}',
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                editProduct(index);
              },
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(),
              iconSize: 22,
              icon: Icon(Icons.edit, color: Color(0xFFFF9800)),
            ),
            SizedBox(width: 8),
            IconButton(
              onPressed: () {
                deleteProduct(index);
              },
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(),
              iconSize: 21,
              icon: Icon(Icons.delete, color: Color(0xFFFF3B30)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = ShoppingData.totalSpending();
    double budgetLeft = ShoppingData.budgetLeft();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 18, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  cancelShopping();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Colors.grey[600],
                ),
                icon: Icon(Icons.arrow_back, size: 18),
                label: Text('Back to Method', style: TextStyle(fontSize: 13)),
              ),
              Text(
                'Shop Well!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 6),
              Text(
                ShoppingData.hasBudget ? 'Current Budget' : 'Total Spending',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              Divider(height: 8),
              Text(
                ShoppingData.hasBudget
                    ? '₱${ShoppingData.money(budgetLeft)}'
                    : '₱${ShoppingData.money(total)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: ShoppingData.hasBudget && budgetLeft <= 0
                      ? Colors.red
                      : Colors.black,
                ),
              ),
              if (ShoppingData.hasBudget && budgetLeft <= 0)
                Text(
                  'Your budget has been emptied. Review your shopping before finishing.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              if (err.isNotEmpty)
                Text(err, style: TextStyle(color: Colors.red, fontSize: 12)),
              SizedBox(height: 12),
              Expanded(
                child: ShoppingData.currentProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/No Products.png',
                              width: 220,
                            ),
                            Text(
                              'No Product yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: ShoppingData.currentProducts.length,
                        itemBuilder: (context, index) {
                          return productCard(index);
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        cancelShopping();
                      },
                      iconSize: 27,
                      icon: Icon(Icons.arrow_back, color: Color(0xFFFFA000)),
                    ),
                    FloatingActionButton(
                      backgroundColor: Color(0xFFFFA000),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/add-product');
                      },
                      child: Icon(Icons.add, size: 28),
                    ),
                    IconButton(
                      onPressed: () {
                        finishShopping();
                      },
                      iconSize: 27,
                      icon: Icon(Icons.flag_outlined, color: Color(0xFFFFA000)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

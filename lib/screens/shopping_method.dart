import 'package:flutter/material.dart';

import '../models/app_preferences.dart';
import '../globs/shopping.dart';

class ShoppingMethodScreen extends StatefulWidget {
  const ShoppingMethodScreen({super.key});

  @override
  State<ShoppingMethodScreen> createState() => ShoppingMethodPage();
}

class ShoppingMethodPage extends State<ShoppingMethodScreen> {
  TextEditingController budgetController = TextEditingController(text: '₱ ');
  String err = '';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
    budgetController.selection = TextSelection.collapsed(
      offset: budgetController.text.length,
    );
  }

  Future<void> _loadCurrency() async {
    await ShoppingData.loadCurrency();
    if (!mounted) return;

    final amount = budgetController.text.replaceAll('₱', '').trim();
    budgetController.text = '${ShoppingData.currency.symbol} $amount';
    budgetController.selection = TextSelection.collapsed(
      offset: budgetController.text.length,
    );
    setState(() {});
  }

  String numbersOnly(String value) {
    String numbers = '0123456789';
    String newValue = '';
    bool hasDecimal = false;
    int decimalNumbers = 0;

    for (int i = 0; i < value.length; i++) {
      String character = value[i];

      if (numbers.contains(character) && newValue.length < 9) {
        if (hasDecimal == false || decimalNumbers < 2) {
          newValue += character;
          if (hasDecimal) decimalNumbers++;
        }
      } else if (character == '.' &&
          hasDecimal == false &&
          newValue.isNotEmpty &&
          newValue.length < 9) {
        newValue += character;
        hasDecimal = true;
      }
    }

    return newValue;
  }

  void continueShopping() {
    String budgetText = budgetController.text.replaceAll('₱', '').trim();
    double? budget = double.tryParse(budgetText);

    if (budgetText.isEmpty) {
      setState(() {
        err = 'Enter a budget or choose Skip.';
      });
    } else if (budget == null || !budget.isFinite || budget <= 1) {
      setState(() {
        err = 'Budget must be greater than 1.';
      });
    } else {
      ShoppingData.startShopping(withBudget: true, budget: budget);
      Navigator.pushNamed(context, '/shopping');
    }
  }

  void skipBudget() {
    ShoppingData.startShopping(withBudget: false);
    Navigator.pushNamed(context, '/shopping');
  }

  void budgetChanged(String value) {
    String amount = value.replaceAll('₱', '').trim();
    amount = numbersOnly(amount);
    String formattedValue = '${ShoppingData.currency.symbol} $amount';

    if (budgetController.text != formattedValue) {
      budgetController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }

    setState(() {
      err = '';
    });
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Colors.grey[600],
                ),
                icon: Icon(Icons.arrow_back, size: 20),
                label: Text('Back to Method', style: TextStyle(fontSize: 14)),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: 350,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'On the Go Shopping',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 32),
                          Text(
                            'How much is your budget?',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: budgetController,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: budgetChanged,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFFD9D9D9),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFFD9D9D9),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF13AD58),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          if (err.isNotEmpty) ...[
                            SizedBox(height: 5),
                            Text(
                              err,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ],
                          SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                continueShopping();
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
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              skipBudget();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Color(0xFF177A3F),
                            ),
                            child: Text(
                              'Skip Budget',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
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

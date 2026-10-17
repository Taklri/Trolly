import 'package:flutter/material.dart';
import '../globs/shopping.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => EditProductPage();
}

class EditProductPage extends State<EditProductScreen> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  String nameErr = '';
  String priceErr = '';
  String quantityErr = '';
  bool showWarning = false;
  bool loaded = false;
  int productIndex = 0;
  double oldProductTotal = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (loaded == false) {
      productIndex = ModalRoute.of(context)!.settings.arguments as int;
      Map<String, dynamic> product = ShoppingData.currentProducts[productIndex];

      productNameController.text = product['productName'];
      priceController.text = product['productPrice'].toString();
      quantityController.text = product['quantity'].toString();
      oldProductTotal = (product['totalAmount'] as num).toDouble();
      loaded = true;
    }
  }

  double productTotal() {
    double price = double.tryParse(priceController.text.trim()) ?? 0;
    int quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    return price * quantity;
  }

  double projectedTotal() {
    return ShoppingData.totalSpending() - oldProductTotal + productTotal();
  }

  double projectedBudget() {
    return ShoppingData.startingBudget - projectedTotal();
  }

  String lettersOnly(String value) {
    String letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ';
    String newValue = '';

    for (int i = 0; i < value.length; i++) {
      if (letters.contains(value[i]) && newValue.length < 30) {
        newValue += value[i];
      }
    }

    return newValue;
  }

  String priceNumbersOnly(String value) {
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

  String quantityNumbersOnly(String value) {
    String numbers = '0123456789';
    String newValue = '';

    for (int i = 0; i < value.length; i++) {
      if (numbers.contains(value[i]) && newValue.length < 3) {
        newValue += value[i];
      }
    }

    return newValue;
  }

  void changeController(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  void fieldChanged(String field, String value) {
    if (field == 'name') {
      changeController(productNameController, lettersOnly(value));
    }

    if (field == 'price') {
      changeController(priceController, priceNumbersOnly(value));
    }

    if (field == 'quantity') {
      changeController(quantityController, quantityNumbersOnly(value));
    }

    setState(() {
      if (field == 'name') nameErr = '';
      if (field == 'price') priceErr = '';
      if (field == 'quantity') quantityErr = '';
      showWarning = false;
    });
  }

  bool validateProduct() {
    String name = productNameController.text.trim();
    String priceText = priceController.text.trim();
    String quantityText = quantityController.text.trim();
    double? price = double.tryParse(priceText);
    int? quantity = int.tryParse(quantityText);

    setState(() {
      nameErr = name.isEmpty
          ? 'Product name is required.'
          : name.length < 2
          ? 'Product name must have at least 2 letters.'
          : name.length > 30
          ? 'Product name can only have up to 30 letters.'
          : ShoppingData.productNameExists(name, exceptIndex: productIndex)
          ? 'Product name already exists.'
          : '';
      priceErr = priceText.isEmpty
          ? 'Product price is required.'
          : price == null || !price.isFinite
          ? 'Enter a valid product price.'
          : price <= 0
          ? 'Product price must be greater than 0.'
          : priceText.length > 9
          ? 'Product price can only have up to 9 numbers.'
          : '';
      quantityErr = quantityText.isEmpty
          ? 'Quantity is required.'
          : quantity == null || quantity <= 0
          ? 'Quantity must be a positive whole number.'
          : quantityText.length > 3
          ? 'Quantity can only have up to 3 numbers.'
          : '';
    });

    return nameErr.isEmpty && priceErr.isEmpty && quantityErr.isEmpty;
  }

  void editProduct() {
    if (validateProduct() == false) return;

    if (ShoppingData.hasBudget && projectedBudget() <= 0) {
      setState(() {
        showWarning = true;
      });
    } else {
      saveProduct();
    }
  }

  void saveProduct() {
    double price = double.parse(priceController.text.trim());
    int quantity = int.parse(quantityController.text.trim());
    Map<String, dynamic> oldProduct =
        ShoppingData.currentProducts[productIndex];

    ShoppingData.currentProducts[productIndex] = {
      'productName': productNameController.text.trim(),
      'productPrice': price,
      'quantity': quantity,
      'totalAmount': price * quantity,
      if (ShoppingData.isGroceryListShopping)
        'checked': oldProduct['checked'] == true,
    };

    Navigator.pushReplacementNamed(context, '/shopping');
  }

  void cancelProduct() {
    Navigator.pushReplacementNamed(context, '/shopping');
  }

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration({String? prefixText}) {
    return InputDecoration(
      prefixText: prefixText,
      filled: true,
      fillColor: Color(0xFFF5F5F5),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = productTotal();
    double displayedAmount = ShoppingData.hasBudget
        ? projectedBudget()
        : projectedTotal();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  cancelProduct();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Colors.grey[600],
                ),
                icon: Icon(Icons.arrow_back, size: 20),
                label: Text('Back to Shopping', style: TextStyle(fontSize: 14)),
              ),
              Text(
                ShoppingData.hasBudget ? 'Current Budget' : 'Total Spending',
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              ),
              Divider(height: 8),
              Text(
                '₱${ShoppingData.money(displayedAmount)}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: ShoppingData.hasBudget && displayedAmount <= 0
                      ? Colors.red
                      : Colors.black,
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Product Name:', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      TextField(
                        controller: productNameController,
                        style: TextStyle(fontSize: 17),
                        onChanged: (value) {
                          fieldChanged('name', value);
                        },
                        decoration: fieldDecoration(),
                      ),
                      if (nameErr.isNotEmpty)
                        Text(
                          nameErr,
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      SizedBox(height: 18),
                      Text('Product Price:', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 220,
                        child: TextField(
                          controller: priceController,
                          style: TextStyle(fontSize: 17),
                          onChanged: (value) {
                            fieldChanged('price', value);
                          },
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: fieldDecoration(prefixText: '₱ '),
                        ),
                      ),
                      if (priceErr.isNotEmpty)
                        Text(
                          priceErr,
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      SizedBox(height: 18),
                      Text('Quantity:', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: quantityController,
                          style: TextStyle(fontSize: 17),
                          onChanged: (value) {
                            fieldChanged('quantity', value);
                          },
                          keyboardType: TextInputType.number,
                          decoration: fieldDecoration(),
                        ),
                      ),
                      if (quantityErr.isNotEmpty)
                        Text(
                          quantityErr,
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      SizedBox(height: 32),
                      summaryRow(
                        'Product Price:',
                        '₱${ShoppingData.money(double.tryParse(priceController.text.trim()) ?? 0)}',
                      ),
                      summaryRow('Quantity:', quantityController.text),
                      Divider(),
                      summaryRow(
                        'Total Amount:',
                        '₱${ShoppingData.money(total)}',
                        bold: true,
                      ),
                      if (ShoppingData.hasBudget)
                        summaryRow(
                          'Budget Left:',
                          '₱${ShoppingData.money(projectedBudget())}',
                          bold: true,
                        )
                      else
                        summaryRow(
                          'Total Spending:',
                          '₱${ShoppingData.money(projectedTotal())}',
                          bold: true,
                        ),
                      if (showWarning) ...[
                        SizedBox(height: 12),
                        Text(
                          'Your budget will be emptied. Do you want to proceed?',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (showWarning)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          saveProduct();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF13AD58),
                          foregroundColor: Colors.white,
                          minimumSize: Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text('Proceed'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            showWarning = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      editProduct();
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
                      'Save Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

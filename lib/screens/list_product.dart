import 'package:flutter/material.dart';

import '../models/app_preferences.dart';
import '../services/currency_service.dart';

const _trollyGreen = Color(0xFF16A34A);
const _trollyText = Color(0xFF171717);
const _trollySecondaryText = Color(0xFF616161);
const _fieldFill = Color(0xFFF5F5F5);
const _danger = Color(0xFFFF3B30);

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => ListProductPage();
}

class ListProductPage extends State<ListProductScreen> {
  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  int? productIndex;
  bool loaded = false;
  bool invalidArguments = false;
  String nameErr = '';
  String priceErr = '';
  String quantityErr = '';
  TrollyCurrency productCurrency = TrollyCurrency.php;

  bool validProductMap(dynamic product) {
    return product is Map<String, dynamic> &&
        product['productName'] is String &&
        product['productPrice'] is num &&
        product['quantity'] is int &&
        product['totalAmount'] is num;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (loaded == false) {
      dynamic arguments = ModalRoute.of(context)?.settings.arguments;

      if (arguments is Map && arguments['products'] is List) {
        dynamic currencyCode = arguments['currencyCode'];
        productCurrency = trollyCurrencyFromCode(
          currencyCode is String ? currencyCode : null,
        );
        List<dynamic> receivedProducts = arguments['products'];
        bool validProducts = true;

        for (int i = 0; i < receivedProducts.length; i++) {
          if (validProductMap(receivedProducts[i]) == false) {
            validProducts = false;
            break;
          }
          products.add(Map<String, dynamic>.from(receivedProducts[i]));
        }

        dynamic receivedIndex = arguments['productIndex'];
        if (receivedIndex != null && receivedIndex is! int) {
          validProducts = false;
        }

        if (validProducts && receivedIndex is int) {
          if (receivedIndex < 0 || receivedIndex >= products.length) {
            validProducts = false;
          } else {
            productIndex = receivedIndex;
            Map<String, dynamic> product = products[receivedIndex];
            productNameController.text = product['productName'].toString();
            priceController.text = (product['productPrice'] as num).toString();
            quantityController.text = product['quantity'].toString();
          }
        }

        invalidArguments = validProducts == false;
      } else {
        invalidArguments = true;
      }

      loaded = true;
    }
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
    });
  }

  bool productNameExists(String name) {
    String newName = name.trim().toLowerCase();

    for (int i = 0; i < products.length; i++) {
      if (productIndex != null && i == productIndex) continue;

      String oldName = products[i]['productName']
          .toString()
          .trim()
          .toLowerCase();
      if (newName == oldName) return true;
    }

    return false;
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
          : productNameExists(name)
          ? 'Product name already exists.'
          : '';
      priceErr = priceText.isEmpty
          ? 'Product price is required.'
          : price == null || !price.isFinite
          ? 'Enter a valid product price.'
          : price <= 0
          ? 'Product price must be greater than 0.'
          : '';
      quantityErr = quantityText.isEmpty
          ? 'Quantity is required.'
          : quantity == null || quantity <= 0 || quantity > 999
          ? 'Quantity must be a positive whole number.'
          : '';
    });

    return nameErr.isEmpty && priceErr.isEmpty && quantityErr.isEmpty;
  }

  void saveProduct() {
    if (validateProduct() == false) return;

    double price = double.parse(priceController.text.trim());
    int quantity = int.parse(quantityController.text.trim());
    Map<String, dynamic> product = {
      'productName': productNameController.text.trim(),
      'productPrice': price,
      'quantity': quantity,
      'totalAmount': price * quantity,
    };

    Navigator.pop(context, product);
  }

  double productTotal() {
    double price = double.tryParse(priceController.text.trim()) ?? 0;
    int quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    return price * quantity;
  }

  String money(double amount) {
    if (amount == 0) return '${productCurrency.symbol}0';

    return CurrencyService.formatMinorUnits(
      (amount * 100).round(),
      productCurrency,
    );
  }

  InputDecoration fieldDecoration({String? prefixText}) {
    return InputDecoration(
      prefixText: prefixText,
      filled: true,
      fillColor: _fieldFill,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget errorText(String error) {
    if (error.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(error, style: const TextStyle(color: _danger, fontSize: 13)),
    );
  }

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (invalidArguments) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Product form could not be opened.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to List'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    double pagePadding = MediaQuery.sizeOf(context).width < 360 ? 16 : 24;
    bool editing = productIndex != null;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pagePadding, 16, pagePadding, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('list-product-back'),
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: _trollySecondaryText,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 21),
                      label: const Text('Back to List'),
                    ),
                  ),
                  Text(
                    editing ? 'Edit Product' : 'Add Product',
                    style: const TextStyle(
                      color: _trollyText,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Product Name',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 7),
                          TextField(
                            key: const Key('list-product-name'),
                            controller: productNameController,
                            maxLength: 30,
                            onChanged: (value) => fieldChanged('name', value),
                            decoration: fieldDecoration(),
                          ),
                          errorText(nameErr),
                          const SizedBox(height: 16),
                          const Text(
                            'Product Price',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 7),
                          TextField(
                            key: const Key('list-product-price'),
                            controller: priceController,
                            maxLength: 9,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) => fieldChanged('price', value),
                            decoration: fieldDecoration(
                              prefixText: '${productCurrency.symbol} ',
                            ),
                          ),
                          errorText(priceErr),
                          const SizedBox(height: 16),
                          const Text(
                            'Quantity',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 7),
                          TextField(
                            key: const Key('list-product-quantity'),
                            controller: quantityController,
                            maxLength: 3,
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                fieldChanged('quantity', value),
                            decoration: fieldDecoration(),
                          ),
                          errorText(quantityErr),
                          const SizedBox(height: 28),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F5EA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Estimated Amount',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                Text(
                                  money(productTotal()),
                                  key: const Key('list-product-total'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      key: const Key('list-product-save'),
                      onPressed: saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _trollyGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        editing ? 'Save Product' : 'Add Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}

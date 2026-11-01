import 'package:flutter/material.dart';

import '../globs/grocery_lists.dart';
import '../models/app_preferences.dart';
import '../services/currency_service.dart';
import '../services/user_preferences.dart';

const _trollyGreen = Color(0xFF16A34A);
const _trollyOrange = Color(0xFFFF9D00);
const _trollyText = Color(0xFF171717);
const _trollySecondaryText = Color(0xFF616161);
const _trollyBorder = Color(0xFFD8D8D8);
const _fieldFill = Color(0xFFF5F5F5);
const _danger = Color(0xFFFF3B30);

class ListCreationScreen extends StatefulWidget {
  const ListCreationScreen({super.key});

  @override
  State<ListCreationScreen> createState() => ListCreationPage();
}

class ListCreationPage extends State<ListCreationScreen> {
  TextEditingController listNameController = TextEditingController();
  List<Map<String, dynamic>> draftProducts = [];
  List<Map<String, dynamic>> originalProducts = [];

  bool loaded = false;
  bool invalidList = false;
  bool allowPop = false;
  int? listId;
  int savedListIndex = -1;
  String originalName = '';
  String nameErr = '';
  String productsErr = '';
  TrollyCurrency listCurrency = TrollyCurrency.php;
  bool currencyLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (loaded == false) {
      dynamic arguments = ModalRoute.of(context)?.settings.arguments;

      if (arguments == null) {
        originalName = '';
      } else if (arguments is Map && arguments['listId'] is int) {
        listId = arguments['listId'];

        for (int i = 0; i < GroceryListData.lists.length; i++) {
          if (GroceryListData.lists[i]['id'] == listId) {
            savedListIndex = i;
            break;
          }
        }

        if (savedListIndex == -1) {
          invalidList = true;
        } else {
          Map<String, dynamic> savedList =
              GroceryListData.lists[savedListIndex];
          originalName = savedList['name'].toString();
          listCurrency = GroceryListData.currencyFor(savedList);
          currencyLoaded = true;
          listNameController.text = originalName;
          draftProducts = copyProducts(savedList['products']);
          originalProducts = copyProducts(savedList['products']);
        }
      } else {
        invalidList = true;
      }

      loaded = true;

      if (invalidList == false && listId == null) {
        loadNewListCurrency();
      }
    }
  }

  Future<void> loadNewListCurrency() async {
    TrollyCurrency currency = await const UserPreferences().readCurrency();
    if (!mounted) return;

    setState(() {
      listCurrency = currency;
      currencyLoaded = true;
    });
  }

  Future<void> ensureCurrencyLoaded() async {
    if (currencyLoaded) return;

    TrollyCurrency currency = await const UserPreferences().readCurrency();
    if (!mounted) return;

    listCurrency = currency;
    currencyLoaded = true;
  }

  List<Map<String, dynamic>> copyProducts(dynamic source) {
    List<Map<String, dynamic>> copiedProducts = [];

    if (source is List) {
      for (int i = 0; i < source.length; i++) {
        if (source[i] is Map<String, dynamic>) {
          copiedProducts.add(Map<String, dynamic>.from(source[i]));
        }
      }
    }

    return copiedProducts;
  }

  bool productsChanged() {
    if (draftProducts.length != originalProducts.length) return true;

    for (int i = 0; i < draftProducts.length; i++) {
      Map<String, dynamic> draft = draftProducts[i];
      Map<String, dynamic> original = originalProducts[i];

      if (draft['productName'] != original['productName'] ||
          draft['productPrice'] != original['productPrice'] ||
          draft['quantity'] != original['quantity'] ||
          draft['totalAmount'] != original['totalAmount']) {
        return true;
      }
    }

    return false;
  }

  bool hasChanges() {
    return listNameController.text != originalName || productsChanged();
  }

  bool listNameExists(String name) {
    String newName = name.trim().toLowerCase();

    for (int i = 0; i < GroceryListData.lists.length; i++) {
      if (listId != null && GroceryListData.lists[i]['id'] == listId) continue;

      String oldName = GroceryListData.lists[i]['name']
          .toString()
          .trim()
          .toLowerCase();
      if (newName == oldName) return true;
    }

    return false;
  }

  double listTotal() {
    double total = 0;

    for (int i = 0; i < draftProducts.length; i++) {
      total += (draftProducts[i]['totalAmount'] as num).toDouble();
    }

    return total;
  }

  String money(double amount) {
    if (amount == 0) return '${listCurrency.symbol}0';

    return CurrencyService.formatMinorUnits(
      (amount * 100).round(),
      listCurrency,
    );
  }

  Future<void> openProductForm({int? index}) async {
    await ensureCurrencyLoaded();
    if (!mounted) return;

    dynamic result = await Navigator.pushNamed(
      context,
      '/list-product',
      arguments: {
        'products': copyProducts(draftProducts),
        'productIndex': index,
        'currencyCode': listCurrency.code,
      },
    );
    if (mounted == false || result is! Map<String, dynamic>) return;

    setState(() {
      if (index == null) {
        draftProducts.add(Map<String, dynamic>.from(result));
      } else {
        draftProducts[index] = Map<String, dynamic>.from(result);
      }
      productsErr = '';
    });
  }

  void confirmRemoveProduct(int index) {
    String productName = draftProducts[index]['productName'].toString();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Product?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text('Remove $productName from this grocery list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              key: const Key('confirm-remove-list-product'),
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  draftProducts.removeAt(index);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void leaveScreen([dynamic result]) {
    setState(() {
      allowPop = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
  }

  void tryLeave() {
    if (hasChanges() == false) {
      leaveScreen();
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Discard changes?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text('Your unsaved list changes will be lost.'),
          actions: [
            TextButton(
              key: const Key('keep-editing-list'),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Keep Editing'),
            ),
            ElevatedButton(
              key: const Key('discard-list-changes'),
              onPressed: () {
                Navigator.pop(dialogContext);
                leaveScreen();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveList() async {
    String name = listNameController.text.trim();

    setState(() {
      nameErr = name.isEmpty
          ? 'List name is required.'
          : listNameExists(name)
          ? 'A list with this name already exists.'
          : '';
      productsErr = draftProducts.isEmpty
          ? 'Add at least one product before saving.'
          : '';
    });

    if (nameErr.isNotEmpty || productsErr.isNotEmpty) return;

    await ensureCurrencyLoaded();
    if (!mounted) return;

    Map<String, dynamic> savedList = {
      'id': listId ?? GroceryListData.nextId,
      'name': name,
      'products': copyProducts(draftProducts),
      'currencyCode': listCurrency.code,
    };

    if (listId == null) {
      GroceryListData.lists.add(savedList);
      GroceryListData.nextId++;
    } else {
      GroceryListData.lists[savedListIndex] = savedList;
    }

    leaveScreen(true);
  }

  Widget productCard(int index) {
    Map<String, dynamic> product = draftProducts[index];
    double price = (product['productPrice'] as num).toDouble();
    double total = (product['totalAmount'] as num).toDouble();

    return Container(
      key: Key('list-product-row-$index'),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _trollyBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['productName'].toString(),
                  style: const TextStyle(
                    color: _trollyText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${money(price)} × ${product['quantity']}',
                  style: const TextStyle(
                    color: _trollySecondaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  money(total),
                  style: const TextStyle(
                    color: _trollyGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: Key('edit-list-product-$index'),
            tooltip: 'Edit ${product['productName']}',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () => openProductForm(index: index),
            icon: const Icon(Icons.edit_outlined, color: _trollyOrange),
          ),
          IconButton(
            key: Key('remove-list-product-$index'),
            tooltip: 'Remove ${product['productName']}',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () => confirmRemoveProduct(index),
            icon: const Icon(Icons.delete_outline, color: _danger),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    listNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (invalidList) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'List not found',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Shop'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    double pagePadding = MediaQuery.sizeOf(context).width < 360 ? 16 : 24;
    bool editing = listId != null;

    return PopScope(
      canPop: allowPop || hasChanges() == false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop == false) tryLeave();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.fromLTRB(pagePadding, 16, pagePadding, 20),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          key: const Key('list-creation-back-button'),
                          onPressed: tryLeave,
                          style: TextButton.styleFrom(
                            foregroundColor: _trollySecondaryText,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(48, 48),
                          ),
                          icon: const Icon(Icons.arrow_back, size: 21),
                          label: const Text('Back to Shop'),
                        ),
                      ),
                      Text(
                        editing ? 'Edit Grocery List' : 'Create Grocery List',
                        style: const TextStyle(
                          color: _trollyText,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('List Name', style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 7),
                      TextField(
                        key: const Key('grocery-list-name'),
                        controller: listNameController,
                        maxLength: 40,
                        onChanged: (value) {
                          setState(() {
                            nameErr = '';
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _fieldFill,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (nameErr.isNotEmpty)
                        Text(
                          nameErr,
                          style: const TextStyle(color: _danger, fontSize: 13),
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 5,
                        spacing: 12,
                        children: [
                          Text(
                            '${draftProducts.length} ${draftProducts.length == 1 ? 'product' : 'products'}',
                            key: const Key('grocery-list-product-count'),
                            style: const TextStyle(
                              color: _trollySecondaryText,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Estimated Total: ${money(listTotal())}',
                            key: const Key('grocery-list-total'),
                            style: const TextStyle(
                              color: _trollyText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Products',
                        style: TextStyle(
                          color: _trollyText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (productsErr.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            productsErr,
                            style: const TextStyle(
                              color: _danger,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (draftProducts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'No products added yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Add products to build your list.',
                                  style: TextStyle(
                                    color: _trollySecondaryText,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: draftProducts.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return productCard(index);
                          },
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          key: const Key('add-list-product'),
                          onPressed: () {
                            openProductForm();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _trollyGreen,
                            side: const BorderSide(color: _trollyGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Add Product',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          key: const Key('save-grocery-list'),
                          onPressed: saveList,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _trollyGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Save List',
                            style: TextStyle(
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
        ),
      ),
    );
  }
}

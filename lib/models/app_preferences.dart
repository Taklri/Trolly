enum TrollyCurrency { php, usd }

extension TrollyCurrencyDetails on TrollyCurrency {
  String get code {
    switch (this) {
      case TrollyCurrency.php:
        return 'PHP';
      case TrollyCurrency.usd:
        return 'USD';
    }
  }

  String get symbol {
    switch (this) {
      case TrollyCurrency.php:
        return '₱';
      case TrollyCurrency.usd:
        return r'$';
    }
  }

  String get label {
    switch (this) {
      case TrollyCurrency.php:
        return 'PHP (₱)';
      case TrollyCurrency.usd:
        return r'USD ($)';
    }
  }
}

TrollyCurrency trollyCurrencyFromCode(String? code) {
  switch (code?.toUpperCase()) {
    case 'USD':
      return TrollyCurrency.usd;
    case 'PHP':
    default:
      return TrollyCurrency.php;
  }
}

enum ShoppingMode { onTheGo, groceryList }

extension ShoppingModeDetails on ShoppingMode {
  String get code {
    switch (this) {
      case ShoppingMode.onTheGo:
        return 'on_the_go';
      case ShoppingMode.groceryList:
        return 'grocery_list';
    }
  }

  String get label {
    switch (this) {
      case ShoppingMode.onTheGo:
        return 'On the go shopping';
      case ShoppingMode.groceryList:
        return 'Use grocery list';
    }
  }
}

ShoppingMode shoppingModeFromCode(String? code) {
  switch (code) {
    case 'grocery_list':
      return ShoppingMode.groceryList;
    case 'on_the_go':
    default:
      return ShoppingMode.onTheGo;
  }
}

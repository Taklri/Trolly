import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trolly/models/app_preferences.dart';
import 'package:trolly/services/user_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('uses PHP and On the go shopping as safe defaults', () async {
    const preferences = UserPreferences();

    expect(await preferences.readName(), isNull);
    expect(await preferences.readCurrency(), TrollyCurrency.php);
    expect(await preferences.readShoppingMode(), ShoppingMode.onTheGo);
  });

  test('persists name, currency, and shopping mode', () async {
    const preferences = UserPreferences();

    await preferences.saveName(' Frankie ');
    await preferences.saveCurrency(TrollyCurrency.usd);
    await preferences.saveShoppingMode(ShoppingMode.groceryList);

    expect(await preferences.readName(), 'Frankie');
    expect(await preferences.readCurrency(), TrollyCurrency.usd);
    expect(await preferences.readShoppingMode(), ShoppingMode.groceryList);
  });
}

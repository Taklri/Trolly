import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences.dart';

class UserPreferences {
  const UserPreferences();

  static const _nameKey = 'trolly.user.name';
  static const _currencyKey = 'trolly.preferences.currency';
  static const _shoppingModeKey = 'trolly.preferences.shopping_mode';

  Future<String?> readName() async {
    final preferences = await SharedPreferences.getInstance();
    final name = preferences.getString(_nameKey)?.trim();
    return name == null || name.isEmpty ? null : name;
  }

  Future<void> saveName(String name) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_nameKey, name.trim());
  }

  Future<TrollyCurrency> readCurrency() async {
    final preferences = await SharedPreferences.getInstance();
    return trollyCurrencyFromCode(preferences.getString(_currencyKey));
  }

  Future<void> saveCurrency(TrollyCurrency currency) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_currencyKey, currency.code);
  }

  Future<ShoppingMode> readShoppingMode() async {
    final preferences = await SharedPreferences.getInstance();
    return shoppingModeFromCode(preferences.getString(_shoppingModeKey));
  }

  Future<void> saveShoppingMode(ShoppingMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_shoppingModeKey, mode.code);
  }
}

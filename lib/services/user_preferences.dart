import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  const UserPreferences();

  static const _userNameKey = 'user_name';

  Future<String?> readName() async {
    final preferences = await SharedPreferences.getInstance();
    final name = preferences.getString(_userNameKey)?.trim();

    if (name == null || name.isEmpty) return null;
    return name;
  }

  Future<void> saveName(String name) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userNameKey, name.trim());
  }
}

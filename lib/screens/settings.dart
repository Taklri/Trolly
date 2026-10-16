import 'package:flutter/material.dart';

import '../globs/activeuser.dart';
import '../models/app_preferences.dart';
import '../services/shopping_history_repository.dart';
import '../services/user_preferences.dart';
import '../widgets/trolly_bottom_navigation.dart';

const _trollyGreen = Color(0xFF16A34A);
const _trollyMint = Color(0xFFE3F5EA);
const _trollyOrange = Color(0xFFFF9D00);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.userPreferences = const UserPreferences(),
    this.historyRepository = const ShoppingHistoryRepository(),
  });

  final UserPreferences userPreferences;
  final ShoppingHistoryRepository historyRepository;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  TrollyCurrency _currency = TrollyCurrency.php;
  ShoppingMode _shoppingMode = ShoppingMode.onTheGo;
  String? _nameError;
  bool _isLoading = true;
  bool _isSavingName = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final values = await Future.wait<Object?>([
      widget.userPreferences.readName(),
      widget.userPreferences.readCurrency(),
      widget.userPreferences.readShoppingMode(),
    ]);
    if (!mounted) return;

    final activeName = ActiveUser.activeUser['fullname']?.toString().trim();
    final savedName = values[0] as String?;
    _nameController.text =
        savedName ??
        (activeName == null || activeName.isEmpty ? '' : activeName);

    setState(() {
      _currency = values[1] as TrollyCurrency;
      _shoppingMode = values[2] as ShoppingMode;
      _isLoading = false;
    });
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Please enter your name.';
      });
      return;
    }

    setState(() {
      _nameError = null;
      _isSavingName = true;
    });

    await widget.userPreferences.saveName(name);
    if (!mounted) return;

    ActiveUser.activeUser = {...ActiveUser.activeUser, 'fullname': name};
    Navigator.of(context).pop(true);
  }

  Future<void> _changeCurrency(TrollyCurrency? currency) async {
    if (currency == null || currency == _currency) return;

    setState(() {
      _currency = currency;
      _hasChanges = true;
    });
    await widget.userPreferences.saveCurrency(currency);
  }

  Future<void> _changeShoppingMode(ShoppingMode? mode) async {
    if (mode == null || mode == _shoppingMode) return;

    setState(() {
      _shoppingMode = mode;
      _hasChanges = true;
    });
    await widget.userPreferences.saveShoppingMode(mode);
  }

  Future<void> _confirmClearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear shopping history?'),
        content: const Text(
          'This will remove all completed shopping sessions. Your name and preferences will stay saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Clear History'),
          ),
        ],
      ),
    );

    if (shouldClear != true) return;
    await widget.historyRepository.clearEntries();
    if (!mounted) return;

    setState(() {
      _hasChanges = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Shopping history cleared.')));
  }

  void _handleNavigation(TrollyNavItem item) {
    if (item == TrollyNavItem.home) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(_hasChanges);
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiScale = (MediaQuery.sizeOf(context).width / 270)
        .clamp(1.0, 1.35)
        .toDouble();

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_hasChanges);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              10 * uiScale,
              12 * uiScale,
              10 * uiScale,
              10 * uiScale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17 * uiScale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3 * uiScale),
                Text(
                  'Personalize your Trolly experience',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 8 * uiScale,
                  ),
                ),
                SizedBox(height: 14 * uiScale),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: _trollyGreen),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: 12 * uiScale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildProfileSection(uiScale),
                              SizedBox(height: 14 * uiScale),
                              _buildPreferencesSection(uiScale),
                              SizedBox(height: 14 * uiScale),
                              _buildDataSection(uiScale),
                            ],
                          ),
                        ),
                ),
                SizedBox(height: 10 * uiScale),
                TrollyBottomNavigation(
                  activeItem: TrollyNavItem.settings,
                  onItemTap: _handleNavigation,
                  uiScale: uiScale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(double uiScale) {
    return _buildSection(
      title: 'Profile',
      uiScale: uiScale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your name',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 9 * uiScale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6 * uiScale),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_nameError != null) {
                setState(() {
                  _nameError = null;
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter your name',
              errorText: _nameError,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10 * uiScale,
                vertical: 8 * uiScale,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
              ),
            ),
          ),
          SizedBox(height: 9 * uiScale),
          SizedBox(
            height: 34 * uiScale,
            child: ElevatedButton(
              onPressed: _isSavingName ? null : _saveName,
              style: ElevatedButton.styleFrom(
                backgroundColor: _trollyGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isSavingName
                  ? SizedBox(
                      width: 16 * uiScale,
                      height: 16 * uiScale,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save Name',
                      style: TextStyle(
                        fontSize: 9 * uiScale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(double uiScale) {
    return _buildSection(
      title: 'Shopping Preferences',
      uiScale: uiScale,
      child: Column(
        children: [
          DropdownButtonFormField<TrollyCurrency>(
            initialValue: _currency,
            decoration: const InputDecoration(
              labelText: 'Currency',
              border: OutlineInputBorder(),
            ),
            items: TrollyCurrency.values
                .map(
                  (currency) => DropdownMenuItem(
                    value: currency,
                    child: Text(currency.label),
                  ),
                )
                .toList(),
            onChanged: _changeCurrency,
          ),
          SizedBox(height: 10 * uiScale),
          DropdownButtonFormField<ShoppingMode>(
            initialValue: _shoppingMode,
            decoration: const InputDecoration(
              labelText: 'Default shopping mode',
              border: OutlineInputBorder(),
            ),
            items: ShoppingMode.values
                .map(
                  (mode) =>
                      DropdownMenuItem(value: mode, child: Text(mode.label)),
                )
                .toList(),
            onChanged: _changeShoppingMode,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(double uiScale) {
    return _buildSection(
      title: 'Data',
      uiScale: uiScale,
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _confirmClearHistory,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear Shopping History'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _trollyOrange,
            side: const BorderSide(color: _trollyOrange),
            padding: EdgeInsets.symmetric(vertical: 9 * uiScale),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required double uiScale,
  }) {
    return Container(
      padding: EdgeInsets.all(11 * uiScale),
      decoration: BoxDecoration(
        color: _trollyMint,
        border: Border.all(color: const Color(0xFFC9E9D4)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 11 * uiScale,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 9 * uiScale),
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../globs/activeuser.dart';
import '../models/app_preferences.dart';
import '../services/shopping_history_repository.dart';
import '../services/user_preferences.dart';

const _trollyGreen = Color(0xFF16A34A);
const _trollyMint = Color(0xFFE3F5EA);
const _trollyMintBorder = Color(0xFFC9E9D4);
const _trollyOrange = Color(0xFFFF9D00);
const _trollyText = Color(0xFF171717);
const _trollySecondaryText = Color(0xFF616161);
const _trollyBorder = Color(0xFFD8D8D8);
const _fieldFill = Color(0xFFF5F5F5);

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

    if (name.length < 2) {
      setState(() {
        _nameError = 'Name must have at least 2 letters.';
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

  void _openHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  Widget _buildBottomNavigation(BuildContext context, double uiScale) {
    return Container(
      height: 68 * uiScale,
      padding: EdgeInsets.symmetric(horizontal: 8 * uiScale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8D8D8)),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Row(
        children: [
          _buildNavigationItem(
            icon: Icons.home_rounded,
            label: 'Home',
            uiScale: uiScale,
            onTap: _openHome,
          ),
          _buildNavigationItem(
            icon: Icons.shopping_cart_outlined,
            label: 'Shop',
            uiScale: uiScale,
            onTap: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/shop', (route) => false),
          ),
          _buildNavigationItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            active: true,
            uiScale: uiScale,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String label,
    required double uiScale,
    bool active = false,
    VoidCallback? onTap,
  }) {
    final color = active ? _trollyGreen : Colors.black45;
    return Expanded(
      child: InkWell(
        key: Key('settings-navigation-${label.toLowerCase()}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 27 * uiScale, color: color),
            SizedBox(height: 2 * uiScale),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12 * uiScale,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiScale = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.9, 1.1)
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18 * uiScale,
                  16 * uiScale,
                  18 * uiScale,
                  16 * uiScale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(uiScale),
                    SizedBox(height: 12 * uiScale),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: _trollyGreen,
                              ),
                            )
                          : SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: 12 * uiScale),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildProfileSection(uiScale),
                                  SizedBox(height: 12 * uiScale),
                                  _buildPreferencesSection(uiScale),
                                  SizedBox(height: 12 * uiScale),
                                  _buildDataSection(uiScale),
                                ],
                              ),
                            ),
                    ),
                    SizedBox(height: 10 * uiScale),
                    _buildBottomNavigation(context, uiScale),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double uiScale) {
    return Row(
      children: [
        Container(
          width: 48 * uiScale,
          height: 48 * uiScale,
          decoration: BoxDecoration(
            color: _trollyMint,
            border: Border.all(color: _trollyMintBorder),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.tune_rounded,
            color: _trollyGreen,
            size: 25 * uiScale,
          ),
        ),
        SizedBox(width: 12 * uiScale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: _trollyText,
                  fontSize: 24 * uiScale,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 3 * uiScale),
              Text(
                'Personalize your Trolly experience',
                style: TextStyle(
                  color: _trollySecondaryText,
                  fontSize: 13 * uiScale,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(double uiScale) {
    return _buildSection(
      title: 'Profile',
      icon: Icons.person_outline_rounded,
      uiScale: uiScale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your name',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13 * uiScale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5 * uiScale),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            maxLength: 10,
            onChanged: (value) {
              const letters =
                  'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ';
              var filtered = '';
              for (var i = 0; i < value.length; i++) {
                if (letters.contains(value[i]) && filtered.length < 10) {
                  filtered += value[i];
                }
              }
              if (_nameController.text != filtered) {
                _nameController.value = TextEditingValue(
                  text: filtered,
                  selection: TextSelection.collapsed(offset: filtered.length),
                );
              }
              if (_nameError != null) {
                setState(() {
                  _nameError = null;
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: _trollySecondaryText,
                size: 20 * uiScale,
              ),
              errorText: _nameError,
              filled: true,
              fillColor: _fieldFill,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14 * uiScale,
                vertical: 8 * uiScale,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _trollyBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _trollyBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _trollyGreen, width: 1.5),
              ),
            ),
          ),
          SizedBox(height: 6 * uiScale),
          SizedBox(
            height: 40 * uiScale,
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
                        fontSize: 14 * uiScale,
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
      icon: Icons.shopping_basket_outlined,
      uiScale: uiScale,
      child: Column(
        children: [
          DropdownButtonFormField<TrollyCurrency>(
            initialValue: _currency,
            decoration: const InputDecoration(
              labelText: 'Currency',
              prefixIcon: Icon(Icons.payments_outlined),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: _fieldFill,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
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
          SizedBox(height: 6 * uiScale),
          DropdownButtonFormField<ShoppingMode>(
            initialValue: _shoppingMode,
            decoration: const InputDecoration(
              labelText: 'Default shopping mode',
              prefixIcon: Icon(Icons.route_outlined),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: _fieldFill,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
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
      icon: Icons.storage_outlined,
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
            padding: EdgeInsets.symmetric(vertical: 14 * uiScale),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    required double uiScale,
  }) {
    return Container(
      padding: EdgeInsets.all(10 * uiScale),
      decoration: BoxDecoration(
        color: _trollyMint,
        border: Border.all(color: _trollyMintBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: _trollyGreen, size: 21 * uiScale),
              SizedBox(width: 7 * uiScale),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: _trollyText,
                    fontSize: 15 * uiScale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * uiScale),
          child,
        ],
      ),
    );
  }
}

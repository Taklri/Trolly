import 'package:flutter/material.dart';

import '../globs/activeuser.dart';
import '../models/app_preferences.dart';
import '../models/shopping_history_entry.dart';
import '../services/currency_service.dart';
import '../services/shopping_history_repository.dart';
import '../services/user_preferences.dart';

const _trollyGreen = Color(0xFF16A34A);
const _trollyMint = Color(0xFFE3F5EA);
const _trollyOrange = Color(0xFFFF9D00);

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.repository = const ShoppingHistoryRepository(),
    this.userPreferences = const UserPreferences(),
  });

  final ShoppingHistoryRepository repository;
  final UserPreferences userPreferences;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ShoppingHistoryEntry> _entries = [];
  bool _isLoading = true;
  TrollyCurrency _displayCurrency = TrollyCurrency.php;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final results = await Future.wait<Object>([
      widget.repository.loadEntries(),
      widget.userPreferences.readCurrency(),
    ]);
    if (!mounted) return;

    setState(() {
      _entries = results[0] as List<ShoppingHistoryEntry>;
      _displayCurrency = results[1] as TrollyCurrency;
      _isLoading = false;
    });
  }

  Future<void> _openSettings() async {
    final changed = await Navigator.of(context).pushNamed('/settings');
    if (!mounted || changed != true) return;

    setState(() => _isLoading = true);
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final uiScale = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.9, 1.1)
        .toDouble();
    final name = ActiveUser.activeUser['fullname']?.toString().trim();
    final displayName = name == null || name.isEmpty ? 'there' : name;
    final totalCentavos = _entries.fold<int>(
      0,
      (total, entry) =>
          total +
          CurrencyService.convertMinorUnits(
            entry.totalCentavos,
            entry.currency,
            _displayCurrency,
          ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24 * uiScale,
            24 * uiScale,
            24 * uiScale,
            22 * uiScale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hello $displayName!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28 * uiScale,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 6 * uiScale),
              Text(
                'Ready to shop? :)',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15 * uiScale,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 22 * uiScale),
              _buildSpendingCard(totalCentavos, uiScale),
              SizedBox(height: 28 * uiScale),
              Text(
                'Shopping History',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22 * uiScale,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 12 * uiScale),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _trollyGreen,
                          ),
                        ),
                      )
                    : _entries.isEmpty
                    ? _buildEmptyState(context, uiScale)
                    : _buildHistoryList(uiScale),
              ),
              SizedBox(height: 16 * uiScale),
              _buildBottomNavigation(context, uiScale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingCard(int totalCentavos, double uiScale) {
    return Container(
      height: 120 * uiScale,
      padding: EdgeInsets.fromLTRB(
        20 * uiScale,
        16 * uiScale,
        14 * uiScale,
        16 * uiScale,
      ),
      decoration: BoxDecoration(
        color: _trollyMint,
        border: Border.all(color: const Color(0xFFC9E9D4)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Spending',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14 * uiScale,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 5 * uiScale),
                Text(
                  CurrencyService.formatMinorUnits(
                    totalCentavos,
                    _displayCurrency,
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28 * uiScale,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/trolly-transparent.png',
            width: 155 * uiScale,
            height: 105 * uiScale,
            fit: BoxFit.contain,
            semanticLabel: 'Trolly grocery cart',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, double uiScale) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/grocery.jpg',
              width: 200 * uiScale,
              height: 165 * uiScale,
              fit: BoxFit.contain,
              semanticLabel: 'No shopping history illustration',
            ),
            SizedBox(height: 10 * uiScale),
            Text(
              'You have no\nShopping History',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20 * uiScale,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            SizedBox(height: 20 * uiScale),
            SizedBox(
              width: 180 * uiScale,
              height: 50 * uiScale,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/shop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _trollyOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  'Start Shopping!',
                  style: TextStyle(
                    fontSize: 15 * uiScale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(double uiScale) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _entries.length,
      separatorBuilder: (_, _) => SizedBox(height: 12 * uiScale),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFD8D8D8)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            key: Key('history-entry-${entry.id}'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/history-summary',
                arguments: entry,
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16 * uiScale,
                14 * uiScale,
                12 * uiScale,
                14 * uiScale,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(entry.completedAt),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12 * uiScale,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 5 * uiScale),
                        Text(
                          entry.title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15 * uiScale,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyService.formatMinorUnits(
                      CurrencyService.convertMinorUnits(
                        entry.totalCentavos,
                        entry.currency,
                        _displayCurrency,
                      ),
                      _displayCurrency,
                    ),
                    style: TextStyle(
                      color: _trollyOrange,
                      fontSize: 16 * uiScale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 6 * uiScale),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black45,
                    size: 24 * uiScale,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
            active: true,
            uiScale: uiScale,
          ),
          _buildNavigationItem(
            icon: Icons.shopping_cart_outlined,
            label: 'Shop',
            uiScale: uiScale,
            onTap: () {
              Navigator.pushNamed(context, '/shop');
            },
          ),
          _buildNavigationItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            uiScale: uiScale,
            onTap: _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String label,
    bool active = false,
    required double uiScale,
    VoidCallback? onTap,
  }) {
    final color = active ? _trollyGreen : Colors.black45;

    return Expanded(
      child: InkWell(
        key: Key('home-navigation-${label.toLowerCase()}'),
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
}

String _formatDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final localDate = date.toLocal();
  return '${months[localDate.month - 1]} ${localDate.day}, ${localDate.year}';
}

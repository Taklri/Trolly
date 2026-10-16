import 'package:flutter/material.dart';

import '../globs/activeuser.dart';
import '../models/shopping_history_entry.dart';
import '../services/shopping_history_repository.dart';

const _trollyGreen = Color(0xFF16A34A);
const _trollyMint = Color(0xFFE3F5EA);
const _trollyOrange = Color(0xFFFF9D00);

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.repository = const ShoppingHistoryRepository(),
  });

  final ShoppingHistoryRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ShoppingHistoryEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final entries = await widget.repository.loadEntries();
    if (!mounted) return;

    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uiScale = (MediaQuery.sizeOf(context).width / 270)
        .clamp(1.0, 1.35)
        .toDouble();
    final name = ActiveUser.activeUser['fullname']?.toString().trim();
    final displayName = name == null || name.isEmpty ? 'there' : name;
    final totalCentavos = _entries.fold<int>(
      0,
      (total, entry) => total + entry.totalCentavos,
    );

    return Scaffold(
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
                'Hello $displayName!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13 * uiScale,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              SizedBox(height: 2 * uiScale),
              Text(
                'Ready to shop? :)',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 7 * uiScale,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 8 * uiScale),
              _buildSpendingCard(totalCentavos, uiScale),
              SizedBox(height: 15 * uiScale),
              Text(
                'Shopping History',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12 * uiScale,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 7 * uiScale),
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
              SizedBox(height: 10 * uiScale),
              _buildBottomNavigation(uiScale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingCard(int totalCentavos, double uiScale) {
    return Container(
      height: 55 * uiScale,
      padding: EdgeInsets.fromLTRB(
        9 * uiScale,
        7 * uiScale,
        7 * uiScale,
        7 * uiScale,
      ),
      decoration: BoxDecoration(
        color: _trollyMint,
        border: Border.all(color: const Color(0xFFC9E9D4)),
        borderRadius: BorderRadius.circular(9),
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
                    fontSize: 7 * uiScale,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2 * uiScale),
                Text(
                  _formatPesos(totalCentavos),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12 * uiScale,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/trolly-transparent.png',
            width: 94 * uiScale,
            height: 54 * uiScale,
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
              width: 125 * uiScale,
              height: 105 * uiScale,
              fit: BoxFit.contain,
              semanticLabel: 'No shopping history illustration',
            ),
            SizedBox(height: 3 * uiScale),
            Text(
              'You have no\nShopping History',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 11 * uiScale,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            SizedBox(height: 11 * uiScale),
            SizedBox(
              width: 96 * uiScale,
              height: 27 * uiScale,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/shop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _trollyOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'Start Shopping!',
                  style: TextStyle(
                    fontSize: 8 * uiScale,
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
      separatorBuilder: (_, _) => SizedBox(height: 7 * uiScale),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return Container(
          padding: EdgeInsets.fromLTRB(
            8 * uiScale,
            6 * uiScale,
            8 * uiScale,
            6 * uiScale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD8D8D8)),
            borderRadius: BorderRadius.circular(7),
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
                        fontSize: 7 * uiScale,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 2 * uiScale),
                    Text(
                      entry.title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8 * uiScale,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatPesos(entry.totalCentavos),
                style: TextStyle(
                  color: _trollyOrange,
                  fontSize: 9 * uiScale,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(double uiScale) {
    return Container(
      height: 40 * uiScale,
      padding: EdgeInsets.symmetric(horizontal: 4 * uiScale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8D8D8)),
        borderRadius: BorderRadius.circular(22),
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
          ),
          _buildNavigationItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            uiScale: uiScale,
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
  }) {
    final color = active ? _trollyGreen : Colors.black45;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19 * uiScale, color: color),
          SizedBox(height: 1 * uiScale),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 7 * uiScale,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPesos(int totalCentavos) {
  final pesos = totalCentavos ~/ 100;
  final centavos = totalCentavos.abs() % 100;
  final groupedPesos = pesos.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );

  if (totalCentavos == 0 || centavos != 0) {
    return '₱$groupedPesos.${centavos.toString().padLeft(2, '0')}';
  }
  return '₱$groupedPesos';
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

import 'package:flutter/material.dart';

const _trollyGreen = Color(0xFF16A34A);
const _trollyMint = Color(0xFFE3F5EA);
const _trollyMintBorder = Color(0xFFC9E9D4);
const _trollyText = Color(0xFF171717);
const _trollySecondaryText = Color(0xFF616161);
const _trollyBorder = Color(0xFFD8D8D8);

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uiScale = (MediaQuery.sizeOf(context).width / 390)
        .clamp(0.9, 1.1)
        .toDouble();

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
                'Shop',
                style: TextStyle(
                  color: _trollyText,
                  fontSize: 30 * uiScale,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 20 * uiScale),
              _buildShoppingCard(context, uiScale),
              SizedBox(height: 28 * uiScale),
              _buildListHeading(context, uiScale),
              SizedBox(height: 12 * uiScale),
              Expanded(child: _buildEmptyState(uiScale)),
              SizedBox(height: 16 * uiScale),
              _buildBottomNavigation(context, uiScale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingCard(BuildContext context, double uiScale) {
    return Container(
      padding: EdgeInsets.all(18 * uiScale),
      decoration: BoxDecoration(
        color: _trollyMint,
        border: Border.all(color: _trollyMintBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to shop?',
            style: TextStyle(
              color: _trollyText,
              fontSize: 19 * uiScale,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4 * uiScale),
          Text(
            'Track your spending as you go',
            style: TextStyle(
              color: _trollySecondaryText,
              fontSize: 14 * uiScale,
              height: 1.3,
            ),
          ),
          SizedBox(height: 14 * uiScale),
          SizedBox(
            width: 155 * uiScale,
            height: 48 * uiScale,
            child: ElevatedButton(
              key: const Key('start-shopping-button'),
              onPressed: () {
                Navigator.pushNamed(context, '/choose-method');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _trollyGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Start Shopping',
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

  Widget _buildListHeading(BuildContext context, double uiScale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Lists',
                style: TextStyle(
                  color: _trollyText,
                  fontSize: 22 * uiScale,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 3 * uiScale),
              Text(
                '0 Grocery Lists',
                style: TextStyle(
                  color: _trollySecondaryText,
                  fontSize: 13 * uiScale,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12 * uiScale),
        SizedBox(
          height: 48 * uiScale,
          child: TextButton.icon(
            key: const Key('create-list-button'),
            onPressed: () {
              Navigator.pushNamed(context, '/create-list');
            },
            style: TextButton.styleFrom(
              backgroundColor: _trollyMint,
              foregroundColor: _trollyGreen,
              padding: EdgeInsets.symmetric(horizontal: 15 * uiScale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: _trollyMintBorder),
              ),
            ),
            icon: Icon(Icons.add, size: 18 * uiScale),
            label: Text(
              'Create List',
              style: TextStyle(
                fontSize: 13 * uiScale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(double uiScale) {
    return Center(
      child: SingleChildScrollView(
        child: Image.asset(
          'assets/images/No Grocery List.png',
          width: 220 * uiScale,
          height: 220 * uiScale,
          fit: BoxFit.contain,
          semanticLabel: 'No grocery list',
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, double uiScale) {
    return Container(
      height: 68 * uiScale,
      padding: EdgeInsets.symmetric(horizontal: 8 * uiScale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _trollyBorder),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Row(
        children: [
          _buildNavigationItem(
            icon: Icons.home_outlined,
            label: 'Home',
            uiScale: uiScale,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          _buildNavigationItem(
            icon: Icons.shopping_cart_rounded,
            label: 'Shop',
            active: true,
            uiScale: uiScale,
            onTap: () {},
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
    VoidCallback? onTap,
  }) {
    final color = active ? _trollyGreen : Colors.black45;

    return Expanded(
      child: InkWell(
        key: Key('shop-navigation-${label.toLowerCase()}'),
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

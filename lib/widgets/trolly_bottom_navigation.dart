import 'package:flutter/material.dart';

const _trollyGreen = Color(0xFF16A34A);

enum TrollyNavItem { home, shop, settings }

class TrollyBottomNavigation extends StatelessWidget {
  const TrollyBottomNavigation({
    super.key,
    required this.activeItem,
    required this.onItemTap,
    this.uiScale = 1,
  });

  final TrollyNavItem activeItem;
  final ValueChanged<TrollyNavItem> onItemTap;
  final double uiScale;

  @override
  Widget build(BuildContext context) {
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
          _buildItem(
            item: TrollyNavItem.home,
            icon: Icons.home_rounded,
            label: 'Home',
          ),
          _buildItem(
            item: TrollyNavItem.shop,
            icon: Icons.shopping_cart_outlined,
            label: 'Shop',
          ),
          _buildItem(
            item: TrollyNavItem.settings,
            icon: Icons.settings_outlined,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required TrollyNavItem item,
    required IconData icon,
    required String label,
  }) {
    final active = item == activeItem;
    final color = active ? _trollyGreen : Colors.black45;

    return Expanded(
      child: InkWell(
        onTap: () => onItemTap(item),
        borderRadius: BorderRadius.circular(18),
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
      ),
    );
  }
}

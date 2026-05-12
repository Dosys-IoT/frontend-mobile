import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class DosysBottomNav extends StatelessWidget {
  final int currentIndex;

  const DosysBottomNav({super.key, required this.currentIndex});

  static const _routes = ['/home', '/medications', '/device', '/insights', '/profile'];
  static const _labels = ['Home', 'Meds', 'Device', 'Insights', 'Profile'];
  static const _icons = [
    Icons.home_outlined,
    Icons.medication_outlined,
    Icons.grid_view_outlined,
    Icons.bar_chart_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) => _NavItem(
              icon: _icons[i],
              label: _labels[i],
              selected: currentIndex == i,
              onTap: () {
                if (currentIndex != i) context.go(_routes[i]);
              },
            )),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

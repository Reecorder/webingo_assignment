import "package:booking_app/app/theme/app_colors.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

// This code is kept minimal because as there is no adjacent screens associated other than the flight screens
class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});

  // Icons kept close to the UI - Better to use the images used
  final List<IconData> bottomItems = [
    LucideIcons.house,
    LucideIcons.plane,
    LucideIcons.bookmark,
    LucideIcons.user,
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 4,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.disabled,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items:
          bottomItems.map((item) => BottomNavigationBarItem(label: "", icon: Icon(item))).toList(),
    );
  }
}

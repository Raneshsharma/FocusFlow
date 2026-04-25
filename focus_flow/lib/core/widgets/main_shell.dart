import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/focus')) return 0;
    if (location.startsWith('/flow')) return 1;
    if (location.startsWith('/library')) return 2;
    if (location.startsWith('/rest')) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/focus');
        break;
      case 1:
        context.go('/flow');
        break;
      case 2:
        context.go('/library');
        break;
      case 3:
        context.go('/rest');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _onItemTapped(context, index),
            backgroundColor: Colors.white,
            indicatorColor: AppColors.amber.withOpacity(0.2),
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              _NavDestination(
                iconPath: AppIcons.navFocus,
                label: 'Focus',
                isSelected: selectedIndex == 0,
              ),
              _NavDestination(
                iconPath: AppIcons.navFlow,
                label: 'Flow',
                isSelected: selectedIndex == 1,
              ),
              _NavDestination(
                iconPath: AppIcons.navLibrary,
                label: 'Library',
                isSelected: selectedIndex == 2,
              ),
              _NavDestination(
                iconPath: AppIcons.navRest,
                label: 'Rest',
                isSelected: selectedIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;

  const _NavDestination({
    required this.iconPath,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: AppIcon(
        iconPath,
        size: 24,
        color: isSelected ? null : AppColors.grey500,
      ),
      selectedIcon: AppIcon(
        iconPath,
        size: 24,
        color: AppColors.amber,
      ),
      label: label,
    );
  }
}
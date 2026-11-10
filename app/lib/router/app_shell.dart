import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/tokens.dart';

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _Destination('Home', Icons.space_dashboard_outlined, Icons.space_dashboard),
  _Destination('Discover', Icons.travel_explore_outlined, Icons.travel_explore),
  _Destination('Companies', Icons.apartment_outlined, Icons.apartment),
  _Destination('Mail', Icons.mail_outline, Icons.mail),
  _Destination('Profile', Icons.person_outline, Icons.person),
];

/// Responsive shell: bottom navigation on phones, navigation rail on tablets / web.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _go(int index) =>
      navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final index = navigationShell.currentIndex;

    if (width < SsBreakpoints.medium) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: SsColors.border)),
          ),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: _go,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (final d in _destinations)
                NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
            ],
          ),
        ),
      );
    }

    final extended = width >= SsBreakpoints.expanded;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: _go,
            extended: extended,
            labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: SsSpace.lg),
              child: extended ? const _Wordmark() : const Icon(Icons.anchor, color: SsColors.accent),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.anchor, color: SsColors.accent, size: 22),
        SizedBox(width: SsSpace.sm),
        Text('SEA SPACE', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 2, fontSize: 14)),
      ],
    );
  }
}

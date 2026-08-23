import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'responsive_container.dart';

class FlewsBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FlewsBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const _items = <({IconData icon, IconData activeIcon, String label})>[
    (
      icon: Icons.newspaper_outlined,
      activeIcon: Icons.newspaper_rounded,
      label: 'Noticias',
    ),
    (
      icon: Icons.mic_none_rounded,
      activeIcon: Icons.mic_rounded,
      label: 'Críticas',
    ),
    (
      icon: Icons.bookmark_border_rounded,
      activeIcon: Icons.bookmark_rounded,
      label: 'Guardados',
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Mi Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceColor,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.borderColor, width: 1.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: ResponsiveContainer(
              maxWidth: 520,
              child: Row(
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final selected = selectedIndex == index;
                  final color = selected
                      ? AppTheme.amberAccent
                      : AppTheme.textSecondary;

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: item.label,
                      child: InkWell(
                        key: ValueKey('bottom-nav-$index'),
                        onTap: () => onSelected(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selected ? item.activeIcon : item.icon,
                              size: 21,
                              color: color,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

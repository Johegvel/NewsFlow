import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FlewsSectionSwitcher extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FlewsSectionSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          _Option(
            label: '📰 Noticias Curadas',
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
          _Option(
            label: '🎙️ Críticas y Análisis',
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppTheme.amberAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppTheme.darkBackground : AppTheme.bodyText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

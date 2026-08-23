import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlewsAppBarTitle extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool showTagline;

  const FlewsAppBarTitle({
    super.key,
    this.iconSize = 36,
    this.fontSize = 22,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/flews_icon.png',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.newspaper_rounded,
                color: AppTheme.amberAccent,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: AppTheme.sansFont,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppTheme.textPrimary,
                ),
                children: const [
                  TextSpan(text: 'Flew'),
                  TextSpan(
                    text: 's',
                    style: TextStyle(color: AppTheme.amberAccent),
                  ),
                ],
              ),
            ),
            if (showTagline)
              const Text(
                'FEW NEWS • CURATED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

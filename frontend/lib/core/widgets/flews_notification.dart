import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlewsNotificationHelper {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    IconData? actionIcon,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 12,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F141F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.amberAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.amberAccent.withValues(alpha: 0.15),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Flews Official Logo Badge for instant recognition
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.amberAccent.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    'assets/images/flews_notification_icon.png',
                    width: 42,
                    height: 42,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.newspaper_rounded,
                      color: AppTheme.amberAccent,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Notification Content
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(text: 'FLEW'),
                              TextSpan(
                                text: 'S',
                                style: TextStyle(
                                  color: AppTheme.amberAccent,
                                ),
                              ),
                              TextSpan(
                                text: ' • AVISO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFCBD5E1),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (actionIcon != null && onAction != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onAction,
                  icon: Icon(actionIcon, color: AppTheme.amberAccent, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

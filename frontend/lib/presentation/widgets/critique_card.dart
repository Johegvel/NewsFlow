import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/post_entity.dart';

class CritiqueCard extends StatelessWidget {
  final PostEntity critique;
  final VoidCallback onTap;

  const CritiqueCard({
    super.key,
    required this.critique,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.amberAccent.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author & Critique Badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppTheme.amberAccent,
                      child: Text(
                        critique.userName.isNotEmpty
                            ? critique.userName.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            critique.userName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Crítica Editorial • Comunidad',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.amberAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Text(
                        critique.communityName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Critique Headline
                Text(
                  critique.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Critique Body Text
                Text(
                  critique.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFCBD5E1),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Bottom hint
                Row(
                  children: [
                    const Icon(Icons.forum_outlined, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    const Text(
                      'Ver análisis completo y debatir',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppTheme.amberAccent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostContentMetadata {
  final String body;
  final String? relevance;
  final String? source;
  final String? originalLink;

  const PostContentMetadata({
    required this.body,
    this.relevance,
    this.source,
    this.originalLink,
  });
}

class CritiqueContentMetadata {
  final String body;
  final String stance;
  final String? quotedTitle;
  final String? quotedCommunity;
  final int? quotedPostId;

  const CritiqueContentMetadata({
    required this.body,
    required this.stance,
    this.quotedTitle,
    this.quotedCommunity,
    this.quotedPostId,
  });
}

PostContentMetadata parsePostContent(String content) {
  String? relevance;
  String? source;
  String? originalLink;
  final bodyLines = <String>[];

  for (final rawLine in content.split('\n')) {
    final line = rawLine.trim();
    if (line.startsWith('• 📊 Relevancia:')) {
      relevance = line.replaceFirst('• 📊 Relevancia:', '').trim();
    } else if (line.startsWith('• Fuente:')) {
      source = line.replaceFirst('• Fuente:', '').trim();
    } else if (line.startsWith('• Enlace original:')) {
      originalLink = line.replaceFirst('• Enlace original:', '').trim();
    } else if (line.isNotEmpty) {
      bodyLines.add(line);
    }
  }

  return PostContentMetadata(
    body: bodyLines.join('\n\n'),
    relevance: relevance,
    source: source,
    originalLink: originalLink,
  );
}

CritiqueContentMetadata parseCritiqueContent(String content) {
  var stance = 'Crítica Constructiva';
  String? quotedTitle;
  String? quotedCommunity;
  int? quotedPostId;
  final bodyLines = <String>[];

  for (final rawLine in content.split('\n')) {
    final line = rawLine.trim();
    if (line.startsWith('[') && line.endsWith(']') && line.length > 2) {
      stance = line.substring(1, line.length - 1);
    } else if (line.startsWith('📌 Noticia Citada:')) {
      quotedTitle = line
          .replaceFirst('📌 Noticia Citada:', '')
          .trim()
          .replaceAll('"', '');
    } else if (line.startsWith('🔗 ID Noticia:')) {
      quotedPostId = int.tryParse(line.replaceFirst('🔗 ID Noticia:', '').trim());
    } else if (line.startsWith('🏛️ Comunidad:')) {
      quotedCommunity = line.replaceFirst('🏛️ Comunidad:', '').trim();
    } else if (line.isNotEmpty && !line.startsWith('─')) {
      bodyLines.add(line);
    }
  }

  return CritiqueContentMetadata(
    body: bodyLines.join('\n\n'),
    stance: stance,
    quotedTitle: quotedTitle,
    quotedCommunity: quotedCommunity,
    quotedPostId: quotedPostId,
  );
}

String communityEmoji(String? slug, String name) {
  final value = '${slug ?? ''} $name'.toLowerCase();
  if (value.contains('salud')) return '🩺';
  if (value.contains('tecnolog') || value.contains('inteligencia')) return '💻';
  if (value.contains('ciencia')) return '🔬';
  if (value.contains('ciber')) return '🛡️';
  if (value.contains('deport')) return '⚽';
  if (value.contains('gastr')) return '🍽️';
  if (value.contains('negocio')) return '📈';
  if (value.contains('social')) return '⚖️';
  if (value.contains('filosof')) return '💡';
  return '📰';
}

String formatRelativeDate(String? rawDate, {String prefix = ''}) {
  final parsed = rawDate == null ? null : DateTime.tryParse(rawDate)?.toLocal();
  if (parsed == null) return '${prefix}Recientemente';

  final difference = DateTime.now().difference(parsed);
  if (difference.inMinutes < 1) return '${prefix}Ahora';
  if (difference.inMinutes < 60) {
    return '${prefix}Hace ${difference.inMinutes} min';
  }
  if (difference.inHours < 24) return '${prefix}Hace ${difference.inHours} h';
  if (difference.inDays < 7) return '${prefix}Hace ${difference.inDays} días';
  return '$prefix${parsed.day.toString().padLeft(2, '0')}/'
      '${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
}

String initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'U';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

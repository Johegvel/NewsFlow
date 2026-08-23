import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/post_formatters.dart';

void main() {
  test(
    'extracts editorial metadata without leaking it into the article body',
    () {
      final metadata = parsePostContent('''
Texto principal de la noticia.

• 📊 Relevancia: 9.4/10
• Fuente: Flews Editorial
• Enlace original: https://example.com/noticia
''');

      expect(metadata.body, 'Texto principal de la noticia.');
      expect(metadata.relevance, '9.4/10');
      expect(metadata.source, 'Flews Editorial');
      expect(metadata.originalLink, 'https://example.com/noticia');
    },
  );

  test('extracts stance and quoted news from a critique', () {
    final metadata = parseCritiqueContent('''
[Crítica Constructiva]
El análisis necesita más evidencia.

────────────────────────────
📌 Noticia Citada: "Una noticia relevante"
🏛️ Comunidad: Ciencia
''');

    expect(metadata.stance, 'Crítica Constructiva');
    expect(metadata.body, 'El análisis necesita más evidencia.');
    expect(metadata.quotedTitle, 'Una noticia relevante');
    expect(metadata.quotedCommunity, 'Ciencia');
  });
}

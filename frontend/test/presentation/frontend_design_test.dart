import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/flews_bottom_navigation.dart';
import 'package:frontend/domain/entities/post_entity.dart';
import 'package:frontend/presentation/screens/auth/auth_screen.dart';
import 'package:frontend/presentation/screens/profile/profile_page.dart';
import 'package:frontend/presentation/widgets/critique_card.dart';
import 'package:frontend/presentation/widgets/post_card.dart';
import 'package:frontend/service_locator.dart';

void main() {
  void useMobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(Widget child) =>
      MaterialApp(theme: AppTheme.darkTheme, home: child);

  testWidgets('auth design fits a mobile viewport and exposes both modes', (
    tester,
  ) async {
    useMobileViewport(tester);
    await tester.pumpWidget(app(const AuthScreen()));

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-button')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Crear Cuenta').first);
    await tester.pumpAndSettle();

    expect(find.text('Únete a la comunidad'), findsOneWidget);
    expect(find.byKey(const ValueKey('register-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom navigation reports the selected Flews section', (
    tester,
  ) async {
    useMobileViewport(tester);
    var selected = 0;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: FlewsBottomNavigation(
              selectedIndex: selected,
              onSelected: (index) => setState(() => selected = index),
            ),
          ),
        ),
      ),
    );

    final navigationRect = tester.getRect(find.byType(FlewsBottomNavigation));
    expect(navigationRect.height, 66);
    expect(navigationRect.bottom, 844);

    await tester.tap(find.byKey(const ValueKey('bottom-nav-2')));
    await tester.pump();

    expect(selected, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('news and critique cards render editorial content without overflow', (
    tester,
  ) async {
    useMobileViewport(tester);
    const news = PostEntity(
      id: 1,
      title: 'La inteligencia artificial transforma el diagnóstico preventivo',
      content:
          'Un nuevo modelo anticipa riesgos.\n\n• 📊 Relevancia: 9.4/10\n• Fuente: Flews Editorial',
      postType: 'opinion',
      userId: 1,
      userName: 'Flews Editorial',
      communityId: 1,
      communityName: 'Salud',
      communitySlug: 'salud',
    );
    const critique = PostEntity(
      id: 2,
      title: 'La precisión clínica también necesita explicabilidad',
      content:
          '[Crítica Constructiva]\nLa adopción debe incluir auditorías.\n📌 Noticia Citada: "La IA transforma el diagnóstico"\n🏛️ Comunidad: Salud',
      postType: 'critique',
      userId: 2,
      userName: 'Juan Pérez',
      communityId: 1,
      communityName: 'Salud',
      commentsCount: 2,
    );

    await tester.pumpWidget(
      app(
        Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [PostCard(post: news, onTap: () {})],
          ),
        ),
      ),
    );

    expect(find.text('Flews Editorial'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'news card overflowed');

    await tester.pumpWidget(
      app(
        Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [CritiqueCard(critique: critique, onTap: () {})],
          ),
        ),
      ),
    );

    expect(find.text('Ver análisis completo'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'critique card overflowed');
  });

  testWidgets('profile exposes the three functional configuration entries', (
    tester,
  ) async {
    useMobileViewport(tester);
    ServiceLocator.init();

    await tester.pumpWidget(app(const ProfilePage()));
    await tester.pump();

    expect(find.text('Configuración de Cuenta'), findsOneWidget);
    expect(find.text('Ajustes de privacidad y datos'), findsOneWidget);
    expect(find.text('Preferencias de Notificaciones'), findsOneWidget);
    expect(find.text('Transparencia Editorial'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

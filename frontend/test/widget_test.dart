import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/service_locator.dart';

void main() {
  setUp(() {
    ServiceLocator.init();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NewsFlowApp());
    expect(find.byType(NewsFlowApp), findsOneWidget);
  });
}

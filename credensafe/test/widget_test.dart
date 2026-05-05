import 'package:flutter_test/flutter_test.dart';

import 'package:credensafe/app/app.dart';

void main() {
  testWidgets('renders configuration error screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const CredenSafeApp(configurationError: 'missing .env'),
    );

    expect(find.text('Configuración incompleta'), findsOneWidget);
  });
}

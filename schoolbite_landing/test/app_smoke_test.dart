import 'package:flutter_test/flutter_test.dart';
import 'package:schoolbite_landing/main.dart';

void main() {
  testWidgets('renders SchoolBite landing', (tester) async {
    await tester.pumpWidget(const SchoolBiteLanding());
    await tester.pumpAndSettle();

    expect(find.text('SchoolBite'), findsWidgets);
    expect(find.text('Olvidese de los pedidos por WhatsApp.'), findsOneWidget);
    expect(find.text('Probar demo para padres'), findsOneWidget);
    expect(find.text('Probar panel de soda'), findsOneWidget);
  });
}

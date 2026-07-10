import 'package:flutter_test/flutter_test.dart';
import 'package:schoolbite_parent/main.dart';

void main() {
  testWidgets('renders parent demo entry', (tester) async {
    await tester.pumpWidget(const SchoolBiteParentApp());
    await tester.pump();
    expect(find.textContaining('!'), findsWidgets);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Entrar a la app'), findsOneWidget);
  });
}

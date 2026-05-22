import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_kds_app/app.dart';
import 'package:pos_kds_app/app_role.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('combined app boots', (tester) async {
    await tester.pumpWidget(
      const PosKdsApp(role: AppRole.combined),
    );

    await tester.pumpAndSettle();

    expect(find.text('Frontdesk'), findsOneWidget);
    expect(find.text('Kitchen'), findsOneWidget);
    expect(find.text('Backoffice'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_kds_app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const PosKdsApp());
    expect(find.text('前台頁骨架已建立，下一步接控制器與 keypad'), findsOneWidget);
  });
}

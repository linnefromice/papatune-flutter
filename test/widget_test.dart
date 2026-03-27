import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:papetune/main.dart';
import 'package:papetune/services/storage_service.dart';

void main() {
  testWidgets('App launches and shows onboarding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    await tester.pumpWidget(PapetuneApp(storage: storage));

    expect(find.text('お子さんの年齢を教えてください'), findsOneWidget);
  });
}

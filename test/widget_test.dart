import 'package:flutter_test/flutter_test.dart';
import 'package:osprey_mvp_app/main.dart';

void main() {
  testWidgets('App renders bottom navigation', (tester) async {
    await tester.pumpWidget(const OspreyApp());
    expect(find.text('Capture'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });
}

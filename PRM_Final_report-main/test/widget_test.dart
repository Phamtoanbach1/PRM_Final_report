import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:prm_final_report/main.dart';

void main() {
  testWidgets('Boat app opens home screen', (WidgetTester tester) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await tester.pumpWidget(const BoatBookingApp());
    await tester.pump();

    expect(find.text('Boat Booking'), findsOneWidget);
  });
}

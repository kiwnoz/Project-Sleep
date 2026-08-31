import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleepwise_ai/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SleepWiseApp());
    // แค่เช็คว่าแอปเปิดขึ้นมาได้โดยไม่ error ก็พอสำหรับตอนนี้
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

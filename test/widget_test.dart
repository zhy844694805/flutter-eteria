import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eteria/main.dart';

void main() {
  testWidgets('App starts without crashing', (tester) async {
    await tester.pumpWidget(const EteriaApp());
    
    // 验证应用能够正常启动
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
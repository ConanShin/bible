
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bible_app/main.dart'; // Verify this import path
import 'package:bible_app/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test - Onboarding loads initially', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BibleApp());
    await tester.pumpAndSettle();

    // Verify Onboarding Screen is shown (Step 1 has "성경 읽기 여정을" text)
    expect(find.textContaining('성경 읽기 여정을'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
  });
}


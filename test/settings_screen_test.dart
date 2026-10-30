import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/screens/settings_screen.dart';

// The form is taller than the default 800x600 test window, so a taller
// window lets the Save Settings button be tapped without scrolling.
void useTallWindow(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('SettingsScreen pre-fills saved settings on open', (
    WidgetTester tester,
  ) async {
    useTallWindow(tester);
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(<String, Object>{
      prefAddress: 'Portsmouth Guildhall, PO1 2AJ',
      prefEmail: 'abdul.kadir@portsmouthcc.gov.uk',
      prefPhoneNumber: '1234',
      prefNewsletter: true,
    });

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Portsmouth Guildhall, PO1 2AJ'), findsOneWidget);
    expect(find.text('abdul.kadir@portsmouthcc.gov.uk'), findsOneWidget);
    expect(find.text('1234'), findsOneWidget);
    final Switch switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.value, isTrue);
  });

  testWidgets('Saving settings stores the values and they load again', (
    WidgetTester tester,
  ) async {
    useTallWindow(tester);
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    final Finder addressField = find.widgetWithText(TextField, 'Address');
    final Finder emailField = find.widgetWithText(TextField, 'Email Address');
    final Finder phoneField = find.widgetWithText(TextField, 'Patron Number');

    await tester.enterText(addressField, 'Guildhall, PO1 2AJ');
    await tester.enterText(
      emailField,
      'gerald.vernon-jackson@portsmouthcc.gov.uk',
    );
    await tester.enterText(phoneField, '5678');
    await tester.tap(find.byType(Switch));
    await tester.pump();

    await tester.tap(find.text('SAVE SETTINGS'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Settings saved for gerald.vernon-jackson@portsmouthcc.gov.uk',
      ),
      findsOneWidget,
    );

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    expect(await prefs.getString(prefAddress), 'Guildhall, PO1 2AJ');
    expect(
      await prefs.getString(prefEmail),
      'gerald.vernon-jackson@portsmouthcc.gov.uk',
    );
    expect(await prefs.getString(prefPhoneNumber), '5678');
    expect(await prefs.getBool(prefNewsletter), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Guildhall, PO1 2AJ'), findsOneWidget);
    expect(
      find.text('gerald.vernon-jackson@portsmouthcc.gov.uk'),
      findsOneWidget,
    );
    expect(find.text('5678'), findsOneWidget);
    final Switch reopenedSwitch = tester.widget<Switch>(find.byType(Switch));
    expect(reopenedSwitch.value, isTrue);
  });

  testWidgets('SettingsScreen starts empty when nothing has been saved', (
    WidgetTester tester,
  ) async {
    useTallWindow(tester);
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    final Switch switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.value, isFalse);
    expect(find.text('Settings saved'), findsNothing);
  });
}

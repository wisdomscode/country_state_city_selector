import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:country_state_city_selector/country_state_city_selector.dart';

void main() {
  testWidgets('CountryStateCitySelector renders correctly', (WidgetTester tester) async {
    // Build the widget inside a MaterialApp (needed for context, theme, etc.)
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CountryStateCitySelector(
            assetPath: 'test/assets/countries.json', // 👈 Use test JSON
            countryHintText: 'Choose a nation',
          ),
        ),
      ),
    );

    // Check that the widget exists in the widget tree
    expect(find.byType(CountryStateCitySelector), findsOneWidget);
  });
}

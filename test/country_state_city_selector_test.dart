import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:country_state_city_selector/country_state_city_selector.dart';

void main() {
  testWidgets('CountryStateCitySelector renders correctly', (WidgetTester tester) async {
    // Build the widget inside a MaterialApp (needed for context, theme, etc.)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CountryStateCitySelector(
            onSelectionChanged: (country, state, city) {},
            countryHintText: 'Choose a nation',
          ),
        ),
      ),
    );

    // Check that the widget exists in the widget tree
    expect(find.byType(CountryStateCitySelector), findsOneWidget);
  });
}

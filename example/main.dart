import 'package:flutter/material.dart';
import 'package:country_state_city_selector/country_state_city_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country State City Selector Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _country = '';
  String _state = '';
  String _city = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Country State City Selector")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CountryStateCitySelector(
              enableLabels: true,
              borderColor: const Color(0xFF0734FF),
              borderWidth: 2.0,
              fillColor: const Color(0xFFFFE8F0),
              labelColor: const Color(0xFF2052F5),
              labelFontSize: 18.0,
              labelFontWeight: FontWeight.bold,
              selectedTextColor: const Color(0xFF363B3B),
              selectedTextFontSize: 18,
              selectedTextFontWeight: FontWeight.bold,
              pickerItemTextColor: Colors.blue,
              pickerItemFontSize: 18.0,
              pickerItemFontWeight: FontWeight.bold,
              modalBackgroundColor: const Color(0xFFEEEEEE),
              modalTitleFontSize: 24.0,
              modalTitleColor: const Color(0xFF363534),
              modalTitleFontWeight: FontWeight.bold,
              countryHintText: 'My Country',
              stateHintText: 'My State',
              cityHintText: 'My Local Government',
              verticalPadding: 12.0,
              initialCountry: 'Nigeria',
              initialState: 'Anambra',
              initialCity: 'Ihiala',
              countryTextFieldHintText: "Search For Country",
              stateTextFieldHintText: "Search For State",
              cityTextFieldHintText: "Search For City",
              onSelectionChanged: (String country, String state, String city) {
                setState(() {
                  _country = country;
                  _state = state;
                  _city = city;
                });
              },
              onCountryChanged: (country) {
                // print("User picked country: $country");
              },
              onStateChanged: (state) {
                // print("User picked state: $state");
              },
              onCityChanged: (city) {
                // print("User picked city: $city");
              },
            ),
            const SizedBox(height: 20.0),
            Text("Selected Country: $_country"),
            Text("Selected State: $_state"),
            Text("Selected City: $_city"),
          ],
        ),
      ),
    );
  }
}
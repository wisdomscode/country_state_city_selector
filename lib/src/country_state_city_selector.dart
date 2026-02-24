import 'dart:convert';
import 'dart:async';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CountryStateCitySelector extends StatefulWidget {
  const CountryStateCitySelector({
    super.key,

    required this.onSelectionChanged,

    // Optional callbacks
    this.onCountryChanged,
    this.onStateChanged,
    this.onCityChanged,

    this.enableLabels = true,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.fillColor = Colors.transparent,

    // Label customization
    this.labelColor = Colors.black,
    this.labelFontSize = 14,
    this.labelFontWeight = FontWeight.normal,

    // Hint text / localization
    this.countryHintText = "Select Country",
    this.stateHintText = "Select State/Province",
    this.cityHintText = "Select City",

    // Selected box text customization
    this.selectedTextColor = Colors.black,
    this.selectedTextFontSize = 16,
    this.selectedTextFontWeight = FontWeight.normal,

    // Picker list item customization
    this.pickerItemTextColor = Colors.black,
    this.pickerItemFontSize = 16,
    this.pickerItemFontWeight = FontWeight.normal,

    // Modal background
    this.modalBackgroundColor = const Color.fromRGBO(255, 255, 255, 0.95),

    // Modal title customization
    this.modalTitleColor = Colors.black,
    this.modalTitleFontSize = 18,
    this.modalTitleFontWeight = FontWeight.bold,

    // For Initialization
    this.initialCountry,
    this.initialState,
    this.initialCity,

    // default country
    this.defaultCountry,

    // vertical Padding
    this.verticalPadding = 12,

    // TextField Hint Text
    this.countryTextFieldHintText,
    this.stateTextFieldHintText,
    this.cityTextFieldHintText,
  });

  // Optional selection callback
  final void Function(String country, String state, String city)
  onSelectionChanged;

  // Optional individual callbacks
  final void Function(String country)? onCountryChanged;
  final void Function(String state)? onStateChanged;
  final void Function(String city)? onCityChanged;

  final bool enableLabels;

  // Customization
  final Color borderColor;
  final double borderWidth;
  final Color fillColor;

  // Label customization
  final Color labelColor;
  final double labelFontSize;
  final FontWeight labelFontWeight;

  // Hint text / localization
  final String countryHintText;
  final String stateHintText;
  final String cityHintText;

  // Selected text customization
  final Color selectedTextColor;
  final double selectedTextFontSize;
  final FontWeight selectedTextFontWeight;

  // Picker list item customization
  final Color pickerItemTextColor;
  final double pickerItemFontSize;
  final FontWeight pickerItemFontWeight;

  // Modal background
  final Color modalBackgroundColor;

  // Modal title customization
  final Color modalTitleColor;
  final double modalTitleFontSize;
  final FontWeight modalTitleFontWeight;

  // For Initialization
  final String? initialCountry;
  final String? initialState;
  final String? initialCity;

  // Default Dountry
  final String? defaultCountry;

  final double verticalPadding;

  // TextField hint text
  final String? countryTextFieldHintText;
  final String? stateTextFieldHintText;
  final String? cityTextFieldHintText;

  @override
  State<CountryStateCitySelector> createState() =>
      _CountryStateCitySelectorState();
}

class _CountryStateCitySelectorState extends State<CountryStateCitySelector> {
  List<Map<String, dynamic>> countries = [];
  Map<String, dynamic>? selectedCountry;
  String? selectedState;
  String? selectedCity;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCountryData();
  }

  Future<void> loadCountryData() async {
    final String jsonString = await rootBundle.loadString(
      'packages/country_state_city_selector/assets/countries.json',
    );

    final List<dynamic> jsonList = jsonDecode(jsonString);

    setState(() {
      countries = jsonList.map((c) => c as Map<String, dynamic>).toList();
      isLoading = false;

      //  Step 1: Prefill with initialCountry (highest priority)
      if (widget.initialCountry != null) {
        selectedCountry =
        countries
            .firstWhere(
              (c) =>
          (c["name"] as String).toLowerCase() ==
              widget.initialCountry!.toLowerCase(),
          orElse: () => {},
        )
            .isNotEmpty
            ? countries.firstWhere(
              (c) =>
          (c["name"] as String).toLowerCase() ==
              widget.initialCountry!.toLowerCase(),
        )
            : null;
      }

      //  Step 2: If no initialCountry, use defaultCountry
      if (selectedCountry == null && widget.defaultCountry != null) {
        selectedCountry =
        countries
            .firstWhere(
              (c) =>
          (c["name"] as String).toLowerCase() ==
              widget.defaultCountry!.toLowerCase(),
          orElse: () => {},
        )
            .isNotEmpty
            ? countries.firstWhere(
              (c) =>
          (c["name"] as String).toLowerCase() ==
              widget.defaultCountry!.toLowerCase(),
        )
            : null;
      }

      //  Step 3: Prefill state (only if initialState is provided + valid)
      if (selectedCountry != null && widget.initialState != null) {
        final states = selectedCountry!["states"] as List<dynamic>;
        final stateExists = states.any(
              (s) =>
          (s["name"] as String).toLowerCase() ==
              widget.initialState!.toLowerCase(),
        );
        if (stateExists) {
          selectedState = widget.initialState;
        }
      }

      //  Step 4: Prefill city (only if initialCity is provided + valid)
      if (selectedCountry != null &&
          selectedState != null &&
          widget.initialCity != null) {
        final states = selectedCountry!["states"] as List<dynamic>;
        final stateObj = states.firstWhere(
              (s) => s["name"].toLowerCase() == selectedState!.toLowerCase(),
        );
        final cities = stateObj["cities"] as List<dynamic>;

        final cityExists = cities.any(
              (c) =>
          (c["name"] as String).toLowerCase() ==
              widget.initialCity!.toLowerCase(),
        );
        if (cityExists) {
          selectedCity = widget.initialCity;
        }
      }

      //  Step 5: Trigger callbacks (for prefilled/default values)
      widget.onSelectionChanged(
        selectedCountry?["name"] ?? '',
        selectedState ?? '',
        selectedCity ?? '',
      );

      if (selectedCountry != null)
        widget.onCountryChanged?.call(selectedCountry!["name"]);
      if (selectedState != null) widget.onStateChanged?.call(selectedState!);
      if (selectedCity != null) widget.onCityChanged?.call(selectedCity!);
    });
  }

  void showPicker<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required void Function(T value) onSelected,
    String? hintText,
  }) {
    List<T> filteredItems = items;

    final content = StatefulBuilder(
      builder: (context, setState) {
        return Material(
          color: Colors.transparent,
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: widget.modalBackgroundColor,
                // uses customizable modal background
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 12),
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: widget.modalTitleFontSize,
                        fontWeight: widget.modalTitleFontWeight,
                        color: widget.modalTitleColor,
                      ),
                    ),
                  ),

                  // Search box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: (Platform.isIOS || Platform.isMacOS) && !kIsWeb
                        ? CupertinoSearchTextField(
                      placeholder: hintText ?? "Search and $title",
                      onChanged: (value) {
                        setState(() {
                          filteredItems = items.where((item) {
                            if (item is Map<String, dynamic>) {
                              return item["name"].toLowerCase().contains(
                                value.toLowerCase(),
                              );
                            } else if (item is String) {
                              return item.toLowerCase().contains(
                                value.toLowerCase(),
                              );
                            }
                            return false;
                          }).toList();
                        });
                      },
                    )
                        : TextField(
                      decoration: InputDecoration(
                        hintText: hintText ?? "Search and $title",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredItems = items.where((item) {
                            if (item is Map<String, dynamic>) {
                              return item["name"].toLowerCase().contains(
                                value.toLowerCase(),
                              );
                            } else if (item is String) {
                              return item.toLowerCase().contains(
                                value.toLowerCase(),
                              );
                            }
                            return false;
                          }).toList();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // List of items
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        String displayText;
                        String? emoji;

                        if (item is Map<String, dynamic>) {
                          displayText = item["name"];
                          emoji = item["emoji"];
                        } else {
                          displayText = item.toString();
                        }

                        final bool isSelected;
                        if (item is Map<String, dynamic>) {
                          isSelected =
                              selectedCountry != null &&
                                  selectedCountry!["name"] == displayText;
                        } else {
                          // For state or city items
                          isSelected =
                              (selectedState != null &&
                                  selectedState == displayText) ||
                                  (selectedCity != null &&
                                      selectedCity == displayText);
                        }

                        final row = Row(
                          children: [
                            if (emoji != null)
                              Text(
                                emoji,
                                style: TextStyle(
                                  fontSize: widget.pickerItemFontSize,
                                ),
                              ),
                            if (emoji != null) const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                displayText,
                                style: TextStyle(
                                  fontSize: widget.pickerItemFontSize,
                                  fontWeight: widget.pickerItemFontWeight,
                                  color: isSelected
                                      ? widget.selectedTextColor
                                      : widget.pickerItemTextColor,
                                ),
                              ),
                            ),
                          ],
                        );

                        return (Platform.isIOS || Platform.isMacOS) &&
                            !kIsWeb
                            ? CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          onPressed: () {
                            onSelected(item);
                            Navigator.pop(context);
                          },
                          child: row,
                        )
                            : ListTile(
                          title: row,
                          onTap: () {
                            onSelected(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if ((Platform.isIOS || Platform.isMacOS) && !kIsWeb) {
      showCupertinoModalPopup(context: context, builder: (_) => content);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        builder: (_) => content,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Picker
        if (widget.enableLabels)
          Text(
            widget.countryHintText,
            style: TextStyle(
              color: widget.labelColor,
              fontSize: widget.labelFontSize,
              fontWeight: widget.labelFontWeight,
            ),
          ),
        GestureDetector(
          onTap: () {
            showPicker<Map<String, dynamic>>(
              context: context,
              title: widget.countryHintText,
              items: countries,
              onSelected: (value) {
                setState(() {
                  selectedCountry = value;
                  selectedState = null;
                  selectedCity = null;
                });

                widget.onCountryChanged?.call(selectedCountry?["name"] ?? '');
                widget.onSelectionChanged.call(
                  selectedCountry?["name"] ?? '',
                  selectedState ?? '',
                  selectedCity ?? '',
                );
              },
              hintText: widget.countryTextFieldHintText,
            );
          },
          child: _buildBox(
            selectedCountry?["name"] ?? widget.countryHintText,
            widget.verticalPadding - 4,
            emoji: selectedCountry?["emoji"],
          ),
        ),

        const SizedBox(height: 20),

        // State Picker
        if (widget.enableLabels)
          Text(
            widget.stateHintText,
            style: TextStyle(
              color: widget.labelColor,
              fontSize: widget.labelFontSize,
              fontWeight: widget.labelFontWeight,
            ),
          ),

        GestureDetector(
          onTap: () {
            if (selectedCountry != null) {
              final states = selectedCountry!["states"] as List<dynamic>;
              showPicker<String>(
                context: context,
                title: widget.stateHintText,
                items: states.map((s) => s["name"] as String).toList(),
                onSelected: (value) {
                  setState(() {
                    selectedState = value;
                    selectedCity = null;
                  });

                  widget.onStateChanged?.call(selectedState ?? '');
                  widget.onSelectionChanged.call(
                    selectedCountry?["name"] ?? '',
                    selectedState ?? '',
                    selectedCity ?? '',
                  );
                },
                hintText: widget.stateTextFieldHintText,
              );
            }
          },
          child: _buildBox(
            selectedState ?? widget.stateHintText,
            widget.verticalPadding,
          ),
        ),
        const SizedBox(height: 20),

        // City Picker
        if (widget.enableLabels)
          Text(
            widget.cityHintText,
            style: TextStyle(
              color: widget.labelColor,
              fontSize: widget.labelFontSize,
              fontWeight: widget.labelFontWeight,
            ),
          ),
        GestureDetector(
          onTap: () {
            if (selectedCountry != null && selectedState != null) {
              final states = selectedCountry!["states"] as List<dynamic>;
              final stateObj = states.firstWhere(
                    (s) => s["name"] == selectedState,
              );

              final cities = (stateObj["cities"] as List<dynamic>)
                  .map((c) => c["name"] as String)
                  .toList();

              showPicker<String>(
                context: context,
                title: widget.cityHintText,
                items: cities,
                onSelected: (value) {
                  setState(() {
                    selectedCity = value;
                  });

                  widget.onCityChanged?.call(selectedCity ?? '');
                  widget.onSelectionChanged.call(
                    selectedCountry?["name"] ?? '',
                    selectedState ?? '',
                    selectedCity ?? '',
                  );
                },
                hintText: widget.cityTextFieldHintText,
              );
            }
          },
          child: _buildBox(
            selectedCity ?? widget.cityHintText,
            widget.verticalPadding,
          ),
        ),
      ],
    );
  }

  // Picker TextFields
  Widget _buildBox(String text, double verticalPadding, {String? emoji}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: verticalPadding),
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: widget.fillColor,
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (emoji != null)
                Text(emoji, style: const TextStyle(fontSize: 22)),
              if (emoji != null) const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: widget.selectedTextColor,
                  fontSize: widget.selectedTextFontSize,
                  fontWeight: widget.selectedTextFontWeight,
                ),
              ),
            ],
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
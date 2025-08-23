## [1.0.1] - 2025-08-23
### Added
- Initial release of `CountryStateCitySelector` widget.
- Fully customizable country, state, and city picker.
- Optional callbacks: `onSelectionChanged`, `onCountryChanged`, `onStateChanged`, `onCityChanged`.
- Customizable UI:
  - Labels, hints, and selected text
  - Picker list items
  - Modal background, title, and styling
  - Border, fill color, and general box styling
- Supports search within the pickers.
- Platform-adaptive modal: uses `CupertinoModalPopup` on iOS/macOS and `showModalBottomSheet` on Android/Web.
- Fully compatible with Flutter 3+ and responsive to all screen sizes.


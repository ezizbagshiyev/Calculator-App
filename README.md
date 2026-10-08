# CSC 4360 Assignment 01 — Calculator App

Undergraduate Flutter calculator for CSC 4360.

## Included features
- Core two-operand arithmetic: +, -, ×, ÷
- Theme toggle: light/dark
- Clear / All Clear (AC)
- Error handling for division by zero and incomplete input
- Responsive button grid and readable result display
- Accessibility labels for calculator controls

## Run
```bash
flutter pub get
flutter run
```

## Build APK
```bash
flutter build apk --release
```

Release APK path:
`build/app/outputs/flutter-apk/app-release.apk`

## Test examples
- `7 + 8 =` → `15`
- `9 - 4 =` → `5`
- `6 × 7 =` → `42`
- `20 ÷ 5 =` → `4`
- `8 ÷ 0 =` → `Error` plus recovery message
- Press `AC` after an error → `0`
- Press `=` before entering a second operand → recoverable error

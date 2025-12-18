# Simplistic Calculator

A simple, elegant scientific calculator app built with Flutter. Ready for App Store publication!

## Features

- **Basic arithmetic operations**: Addition, subtraction, multiplication, division
- **Scientific functions**: sin, cos, tan, sqrt, power
- **Arc trigonometric functions**: arcsin, arccos, arctan
- **Advanced operations**: Absolute value, sign, ceiling, floor
- **Mathematical functions**: Natural logarithm, exponential
- **Additional operations**: Factorial, modulo
- **Calculation history**: Review past computations
- **Clean interface**: Intuitive, user-friendly design

## App Store Ready

This app is configured and ready for App Store submission:

- ✅ Professional calculator icon (purple gradient)
- ✅ All required iOS icon sizes generated
- ✅ Privacy manifest (iOS 17+ compliant)
- ✅ Bundle ID: `com.morriswong.calculator`
- ✅ Support website: [simplistic-calculator-support](https://morriswong.github.io/simplistic-calculator-support/)

## Getting Started

### Prerequisites

- Flutter SDK (^3.9.0)
- Xcode (for iOS development)
- Apple Developer account (for App Store submission)

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/morriswong/simplistic-calculator.git
   cd simplistic-calculator
   ```

2. Open in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

3. In Xcode, add the privacy manifest:
   - Right-click "Runner" folder
   - Select "Add Files to Runner..."
   - Navigate to `ios/Runner/PrivacyInfo.xcprivacy`
   - Check "Copy items if needed"
   - Select "Runner" target
   - Click "Add"

### Running the App

For iOS Simulator:
```bash
flutter run
```

For physical device:
```bash
flutter run -d <device-id>
```

## App Store Submission

Complete guides are included:

- **Quick Guide**: `README_APPSTORE.md` - Step-by-step submission guide
- **Detailed Guide**: `PUBLISHING_GUIDE.md` - Comprehensive documentation
- **Support URL**: `SUPPORT_URL.txt` - URL for App Store metadata

### Quick Steps

1. **Register Bundle ID** (Apple Developer Portal)
   - Bundle ID: `com.morriswong.calculator`

2. **Add Privacy File** (in Xcode, see Installation step 3)

3. **Build & Archive**
   - Select "Any iOS Device (arm64)"
   - Product → Archive

4. **Upload to App Store Connect**
   - Distribute App → Upload

5. **Complete Metadata**
   - Use support URL: https://morriswong.github.io/simplistic-calculator-support/

See `README_APPSTORE.md` for detailed instructions.

## Project Structure

```
simplistic-calculator/
├── assets/              # App icon and assets
├── ios/                 # iOS platform code
│   └── Runner/
│       └── PrivacyInfo.xcprivacy  # Privacy manifest
├── lib/                 # Flutter app code
│   └── main.dart       # Main app file
├── support/            # Support website files
├── PUBLISHING_GUIDE.md # Detailed App Store guide
├── README_APPSTORE.md  # Quick submission guide
└── SUPPORT_URL.txt     # Support URL reference
```

## Configuration

- **App Name**: Simplistic Calculator
- **Bundle ID**: com.morriswong.calculator
- **Version**: 1.0.0 (1)
- **Category**: Utilities
- **Privacy**: No data collection
- **Support Email**: morriswch@gmail.com

## Built With

- [Flutter](https://flutter.dev/) - UI framework
- [Riverpod](https://riverpod.dev/) - State management
- [math_expressions](https://pub.dev/packages/math_expressions) - Expression parsing

## License

Copyright 2024 The Flutter team. All rights reserved.
Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

## Support

For questions or issues:
- Email: morriswch@gmail.com
- Support Site: https://morriswong.github.io/simplistic-calculator-support/

---

**Ready to publish!** Follow the guides in `README_APPSTORE.md` to submit to the App Store. 🚀

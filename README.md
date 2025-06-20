# Expense Tracker App

A modern, feature-rich expense tracking application built with Flutter that supports multi-currency
transactions with real-time exchange rates.

## Features

### Core Features

- ✅ **Multi-Currency Support**: Track expenses in different currencies with automatic conversion to
  USD
- ✅ **Real-Time Exchange Rates**: Integration with open.er-api.com for up-to-date currency
  conversion
- ✅ **Expense Categories**: Organize expenses with predefined categories and custom icons
- ✅ **Receipt Attachment**: Capture and attach receipt photos to expenses
- ✅ **Local Storage**: Offline functionality with Hive database
- ✅ **Modern UI**: Clean, intuitive interface following Material Design principles

### Advanced Features

- ✅ **Data Export**: Export expenses to CSV, reach it from profile icon in nav bar
- ✅ **Filtering & Search**: Filter expenses by date ranges
- ✅ **Statistics Dashboard**: Visual overview of income, expenses, and balance
- ✅ **Responsive Design**: Optimized for different screen sizes

### Technical Features

- ✅ **State Management**: BLoC pattern for predictable state management
- ✅ **Clean Architecture**: Separation of concerns with core, data, and presentation layers since it
  is one feature
- ✅ **Automated Testing**: Unit tests
- ✅ **CI/CD Pipeline**: GitHub Actions for automated building and releases
- ✅ **Code Generation**: Automated model generation with build_runner

## Screenshots

| Home Screen                   | Add Expense                 | Settings                              |
|-------------------------------|-----------------------------|---------------------------------------|
| ![Home](screenshots/home.png) | ![Add](screenshots/add.png) | ![Settings](screenshots/settings.png) |

## Getting Started

### Prerequisites

- Flutter SDK (3.32.4 or later)
- Dart SDK (3.8.0 or later)
- Android Studio / Xcode for mobile development
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/KareemMuhammad/Expense_Tracker_App.git
   cd expense_tracker_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

#### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# Build for iOS
flutter build ios --release
```

## Architecture

The app follows Clean Architecture principles with the following structure:

```
lib/
├── core/       # Utils and services
├── data/       # Data source and models management
├── presentation/     # UI screens and BLoC state management
└── main.dart    # App entry point
```

## API Integration

The app integrates with [open.er-api.com](https://open.er-api.com) for real-time exchange rates:

- **Endpoint**: `https://open.er-api.com/v6/latest/{base_currency}`
- **Features**:
    - Free tier with 1,500 requests/month
    - 20+ supported currencies
    - Real-time exchange rates
    - No API key required

## Dependencies

### Core Dependencies

- `flutter_bloc`: State management
- `hive` & `hive_flutter`: Local database
- `http`: API calls
- `equatable`: Value equality

### UI Dependencies

- `image_picker`: Camera/gallery access
- `share_plus`: Data sharing
- `path_provider`: File system access
- `cached_network_image`: Network Image caching

### Development Dependencies

- `build_runner`: Code generation
- `hive_generator`: Model generation
- `flutter_test`: Testing framework

## Testing

Run tests with:

```bash
# Unit tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart
```

## CI/CD

The project includes GitHub Actions workflows for:

- **Continuous Integration**: Code analysis, testing, and formatting checks
- **Build & Release**: Automated building for Android and iOS
- **Release Management**: Automatic release creation with artifacts

### Workflow Files

- `.github/workflows/ci.yml`: Continuous integration
- `.github/workflows/build.yml`: Build and release

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow Dart/Flutter conventions
- Use `dart format` for formatting
- Ensure all tests pass
- Add tests for new features

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [open.er-api.com](https://open.er-api.com) - Exchange rate API
- [Dribbble](https://dribbble.com/shots/24276232-Expense-Tracker-App) - Design inspiration

## Support

For support, email kareemmuhammad9611@gmail.com or create an issue on GitHub.

---

**Built with ❤️ using Flutter**


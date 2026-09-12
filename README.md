# KharchMate 💰

[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.2-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()
[![Offline First](https://img.shields.io/badge/Storage-100%25%20Offline%20First-brightgreen)]()

> **Track your money. Understand your spending. Take control.**

KharchMate is a modern, simple, and intuitive personal finance and expense tracking application built with Flutter. Designed with an offline-first architecture, KharchMate helps you effortlessly log income, track expenses, analyze spending habits, and manage budgets without needing external accounts or third-party APIs.

---

## ✨ Key Features

- 💰 **Income & Expense Tracking**: Rapidly log daily transactions with customizable categories, notes, and dates.
- 📊 **Insightful Dashboards**: Instant breakdown of total balance, total income, and total expenses.
- 🏷️ **Custom Categorization**: Organize transactions with visual category icons and custom tags.
- 📅 **Date-based Filtering**: View daily, weekly, monthly, and yearly transaction history.
- 📈 **Visual Spending Analytics**: Clear charts showing spending breakdowns and financial trends.
- 🎨 **Modern Design System**: Sleek user interface styled with KharchMate's signature warm orange theme and clean Poppins typography.
- 🔒 **Offline-First & Private**: 100% of your financial data remains securely stored on your device.

---

## 🎨 Design System & Theming

- **Theme Color**: Signature Warm Orange (`#FF7A00`)
- **Typography**: [Poppins](assets/fonts/)
  - Thin (`100`)
  - Light (`300`)
  - Regular (`400`)
  - Medium (`500`)
  - SemiBold (`600`)
  - Bold (`700`)
- **Modes**: Designed for both Light and Dark themes.

---

## 📂 Project Structure

```
KharchMate/
├── assets/
│   ├── fonts/                     # Poppins typography family (.ttf)
│   └── images/                    # Visual assets, icons, and illustrations
│
├── lib/
│   ├── main.dart                  # Application entry point
│   ├── di/                        # Dependency injection & service locator
│   ├── enum/                      # Financial enums (PaymentType, PaymentMode)
│   ├── helper/                    # Utility helpers (validation rules)
│   ├── resources/                 # Design tokens (colors, dimens, fonts, icons)
│   ├── router/                    # GoRouter configuration & route definitions
│   ├── services/                  # Persistent services (SecureStorageService)
│   ├── theme/                     # Theme configuration & custom text styles
│   ├── ui/                        # Feature presentation screens (splash, etc.)
│   ├── utility/                   # Global constants and string keys
│   └── widgets/                   # Reusable UI components (buttons, inputs, loaders)
│
├── ARCHITECTURE.md                # Detailed technical architecture specification
└── pubspec.yaml                   # Dependencies, assets & font registrations
```

For detailed architectural principles, state management conventions, and data layer design, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`^3.47.2` or later)
- Dart SDK (`^3.13.2`)
- Android Studio / Xcode for device simulation

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/NipulDaki/KharchMate.git
   cd KharchMate
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   # Run on connected device / emulator
   flutter run
   ```

---

## 📄 License

This project is licensed under the MIT License.

# KharchMate 💰

[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.2-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()
[![Offline First](https://img.shields.io/badge/Storage-100%25%20Offline%20SQLite-brightgreen)]()

> **Track your money. Understand your spending. Take control.**

KharchMate is a modern, simple, and intuitive personal finance and expense tracking application built with Flutter. Engineered with an offline-first SQLite database architecture, KharchMate helps you effortlessly log income, track expenses, analyze spending habits, and manage budgets without requiring cloud accounts, external servers, or third-party APIs.

---

## ✨ Key Features

- 🚀 **Interactive Onboarding**:
  - 3-slide tutorial walkthrough with auto-advance and dot navigation (`WelcomeScreen`).
  - User personalization screen (`UserNameScreen`) capturing both **Full Name** and **Email Address** with instant format validation.
- 💾 **100% Offline SQLite Database**:
  - Embedded SQLite engine with migration runner (`MigrationRunner`) for seamless version upgrades.
  - Dedicated Data Access Objects (DAOs): `UserDao`, `CategoryDao`, `PaymentMethodDao`, `TransactionDao`, and `BudgetDao`.
  - Automatic pre-seeding of default categories (Rent, Food, Transport, Shopping, Salary, Bonus) and payment methods (Cash, HDFC Bank, UPI, Credit Card, Debit Card).
- 💰 **Comprehensive Transaction Management**:
  - Quickly record Expense and Income entries with title, amount, category, payment mode, date, and optional notes.
  - Detailed view screen with receipt paths, payment method details, and delete confirmation.
  - Search and filter transactions by type, category, or keyword.
- 📊 **Dynamic Dashboard & Month-Year Picker**:
  - Live monthly summary calculating Total Income, Total Expenses, and Net Balance.
  - Category spending breakdown and recent transaction list.
  - Interactive bottom sheet for navigating years and selecting specific months.
- 🏷️ **Custom Category Management**:
  - Browse expense and income categories with icons and color tags.
  - Create custom categories with custom icons and color pickers.
- ⚙️ **Customizable Settings & Profile**:
  - Profile card displaying user's registered Full Name and Email Address.
  - Multi-currency picker supporting INR (₹), USD ($), EUR (€), GBP (£), AED (د.إ), CAD (C$), AUD (A$), and JPY (¥).
  - Dark mode switch with preference persistence.
  - Data export, privacy & security info, and secure logout/reset workflow.

---

## 🎨 Design System & Theming

- **Theme Color**: Signature Warm Orange (`#FF7A00`) with vibrant linear gradient accents
- **Typography**: [Poppins](assets/fonts/)
  - Thin (`100`), Light (`300`), Regular (`400`), Medium (`500`), SemiBold (`600`), Bold (`700`)
- **Visual Design**: Rounded cards, clean input borders, high-contrast finance badges (Green for Income, Coral Red for Expense).

---

## 📂 Project Structure

```
KharchMate/
├── assets/
│   ├── fonts/                         # Custom Poppins font family
│   └── images/                        # Brand icons and visual illustrations
│
├── lib/
│   ├── main.dart                      # Application bootstrap & entry point
│   ├── database/                      # SQLite persistence layer
│   │   ├── app_database.dart          # Database open, close & migration orchestration
│   │   ├── database_constants.dart    # Table and column constant definitions
│   │   ├── daos/                      # Data Access Objects
│   │   │   ├── budget_dao.dart        # Monthly and category budget limits
│   │   │   ├── category_dao.dart      # Category querying and insertion
│   │   │   ├── payment_method_dao.dart# Payment method querying and defaults
│   │   │   ├── transaction_dao.dart   # Transaction CRUD, monthly summaries & analytics
│   │   │   └── user_dao.dart          # Profile persistence (name, email, dark mode)
│   │   └── migrations/                # Versioned schema migrations
│   │       ├── database_migration.dart# Abstract migration contract & MigrationRunner
│   │       └── migration_v1.dart      # V1 schema creation and default seeding
│   ├── di/                            # Dependency Injection
│   │   └── service_locator.dart       # Service locator registrations (GetIt / singletons)
│   ├── enum/                          # Financial & payment enumerations
│   │   ├── payment_mode.dart          # UPI, Card, Bank, Cash
│   │   └── payment_type.dart          # Credit, Debit
│   ├── helper/                        # Helper utilities
│   │   └── validation_helper.dart     # Input validation rules (email, non-empty)
│   ├── models/                        # Domain models
│   │   ├── budget_item.dart           # Budget limit entity
│   │   ├── category.dart              # Category entity
│   │   ├── financial_summary.dart     # Monthly financial summary & trend models
│   │   ├── payment_method.dart        # Payment method entity
│   │   ├── transaction_item.dart      # Transaction entity
│   │   └── user_profile.dart          # User profile model (name, email, currency)
│   ├── resources/                     # Design tokens & resource constants
│   │   ├── app_colors.dart            # Palettes, gradients, finance colors
│   │   ├── app_dimension.dart         # Dimensional tokens & spacing
│   │   ├── app_font.dart              # Font families
│   │   ├── app_icons.dart             # Asset icons
│   │   └── resources.dart             # Barrel export
│   ├── router/                        # Routing & navigation
│   │   ├── app_router.dart            # GoRouter configuration & route bindings
│   │   └── app_routes.dart            # AppRoutes enum, paths & names
│   ├── services/                      # Persistent services
│   │   ├── database_service.dart      # Unified SQLite database API
│   │   └── secure_storage_service.dart# Encrypted key-value persistence
│   ├── theme/                         # Theming & typography
│   │   ├── custom_text_style.dart     # Material TextTheme with Poppins
│   │   └── themes.dart                # Light and core theme definitions
│   ├── ui/                            # Feature screens & views
│   │   ├── categories/                # Category listing and add category screens
│   │   ├── dashboard/                 # Financial summary cards & month overview
│   │   ├── onboarding/                # Welcome tutorial & user name/email setup
│   │   ├── settings/                  # User profile, currency, dark mode, logout
│   │   ├── splash/                    # Animated splash screen
│   │   └── transaction/               # Transaction list, details, and add transaction
│   ├── utility/                       # Global constants & string keys
│   └── widgets/                       # Reusable UI components
│       ├── app_loader.dart            # Standard loading overlay
│       ├── app_text_button.dart       # Gradient action buttons
│       ├── app_textformfield.dart     # Form inputs with prefix icons & validation
│       ├── common_listview.dart       # Scrollable lists with empty state handling
│       └── month_year_picker_sheet.dart# Bottom sheet for month-year selection
│
├── test/                              # Automated unit & widget tests
│   ├── add_transaction_test.dart      # Add transaction screen and logic tests
│   ├── categories_test.dart           # Categories screen and management tests
│   ├── database_test.dart             # SQLite migrations, DAOs, and analytics tests
│   ├── settings_test.dart             # Settings screen, currency picker, logout tests
│   ├── transactions_test.dart         # Transactions list, details, and delete tests
│   ├── user_name_screen_test.dart     # Onboarding name and email input tests
│   ├── welcome_screen_test.dart       # Welcome tutorial carousel tests
│   └── widget_test.dart               # Core widget sanity test
│
├── ARCHITECTURE.md                    # Technical architecture & design specification
└── pubspec.yaml                       # Dependencies, fonts & asset bindings
```

For detailed architectural principles, state management conventions, database schemas, and migration mechanisms, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`^3.47.2` or later)
- Dart SDK (`^3.13.2`)
- Android Studio / Xcode for device emulation

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
   flutter run
   ```

4. **Run automated tests**:
   ```bash
   flutter test
   ```

---

## 📄 License

This project is licensed under the MIT License.

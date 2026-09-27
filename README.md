# KharchMate 💰

[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.2-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()
[![Offline First](https://img.shields.io/badge/Storage-100%25%20Offline%20SQLite-brightgreen)]()
[![Monetization](https://img.shields.io/badge/Monetization-Google%20AdMob-F4B400?logo=google)]()
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=githubactions)]()

> **Track your money. Understand your spending. Take control.**

KharchMate is a modern, simple, and intuitive personal finance and expense tracking application built with Flutter. Engineered with an offline-first SQLite database architecture, KharchMate helps you effortlessly log income, track expenses, analyze spending trends with visual charts, and manage budgets without requiring cloud accounts, external servers, or mandatory third-party logins.

---

## ✨ Key Features

- 🚀 **Interactive Onboarding & Profile Setup**:
  - 3-slide tutorial walkthrough with auto-advance and dot indicators (`WelcomeScreen`).
  - User personalization screen (`UserNameScreen`) capturing **Full Name** and **Email Address** with instant regex validation.
  - Dedicated **User Profile Screen** (`UserProfileScreen`) to view and edit personal details and registration stats.

- 💾 **100% Offline Relational Persistence**:
  - Embedded SQLite engine (`sqflite`) with schema migration runner (`MigrationRunner`) for seamless version upgrades.
  - Modular Data Access Objects: `UserDao`, `CategoryDao`, `PaymentMethodDao`, `TransactionDao`, and `BudgetDao`.
  - Automatic pre-seeding of default categories (Rent, Food, Transport, Shopping, Salary, Bonus) and payment modes (Cash, HDFC Bank, UPI, Credit Card, Debit Card).
  - Complete data privacy: all financial data resides strictly on the local device.

- 💰 **Comprehensive Transaction Management & Smart Filters**:
  - Rapidly record Expense and Income entries with title, amount, category, payment mode, date, and optional notes.
  - Detailed view screen with receipt image paths, payment mode details, and delete confirmation.
  - **Multi-Dimensional Filters**: Filter transactions by type (All, Expense, Income), month-year, specific date, or category.
  - **Dynamic Sorting & Search**: Sort by newest, oldest, highest, or lowest amount; debounced real-time search across notes, titles, and categories.

- 📊 **Dynamic Dashboard with Visual Breakdown**:
  - Live monthly summary calculating Total Income, Total Expenses, and Net Balance.
  - Interactive **Pie Chart** (`fl_chart`) visualizing categorical spending with touch inspection.
  - Interactive bottom sheet (`MonthYearPickerSheet`) for seamlessly navigating years and selecting specific months.
  - Recent transactions list with direct drill-down to details.

- 📈 **Visual Reports & Analytics Engine**:
  - Dedicated Reports Screen (`ReportsScreen`) featuring three analytical views:
    - **Overview**: Monthly net balance, income/expense breakdown, savings rate, and interactive pie chart.
    - **Category Breakdown**: Percentage share, category icons, and total spent per category.
    - **Monthly Trends**: 6-month comparative bar chart comparing historical income against expenses.

- 🏷️ **Smart Category System**:
  - Browse expense and income categories with icons, color badges, and default tags.
  - Create custom categories with custom icons and color pickers.
  - Intelligent icon resolver (`CategoryModel.iconDataFrom`) matching 50+ keywords to Material icons.

- 🛡️ **Monetization & 3-Day Ad-Free Reward Pass**:
  - Integrated Google AdMob (`google_mobile_ads`) with adaptive banner ads on the Dashboard.
  - **3-Day Ad-Free Reward**: Watch a rewarded video ad to unlock a 3-day ad-free pass, stored securely in encrypted storage.
  - Extendable duration: Watching additional rewarded ads cumulatively extends the ad-free period.
  - Automatic ad suppression across the app while the pass is active.

- ⚙️ **Customizable Settings & In-App Review**:
  - Interactive Currency Picker supporting INR (₹) and extensible to global currencies.
  - Direct shortcuts to Category Management.
  - In-App Google Play Store review integration ("Rate & Review Us").
  - Dynamic app version display via `package_info_plus`.
  - **Complete Data Deletion ("Delete My Data")**: Securely erase all transactions, budgets, and custom records while retaining default seeds.

- 📄 **Legal Compliance & Hosted Web Pages**:
  - In-app viewers for **Privacy Policy**, **Terms of Use**, and **Help & Support** with searchable FAQs.
  - Hosted static web pages (`docs/`): Landing page, Privacy Policy, Terms of Service, Support, and Data Deletion request page conforming to Google Play policies.

- 🤖 **Multi-Environment Flavors & CI/CD Pipeline**:
  - Environment configuration (`AppConfig`) supporting **Development**, **Staging**, and **Production**.
  - Dynamic AdMob ID resolution (Google official test IDs for dev/staging, live production IDs for prod).
  - Automated **GitHub Actions CI/CD Pipeline** building signed release Android App Bundles (`.aab`) and APKs (`.apk`) with automated GitHub Releases.

---

## 🎨 Design System & Theming

- **Theme Color**: Signature Warm Orange (`#FF7A00`) with vibrant linear gradient accents (`#E65100` ➔ `#FF7A00` ➔ `#FF9800`)
- **Typography**: [Poppins](assets/fonts/)
  - Thin (`100`), Light (`300`), Regular (`400`), Medium (`500`), SemiBold (`600`), Bold (`700`)
- **Visual Badges**: High-contrast indicators (Green `#1A6C45` for Income, Coral Red `#F44336` for Expense, Teal `#00897B` for Balance/Savings)
- **Component Styling**: Rounded cards, clean input borders, reactive bottom sheets, and center-docked navigation bar.

---

## 📂 Project Structure

```
KharchMate/
├── .github/
│   └── workflows/
│       └── deploy.yml                 # GitHub Actions CI/CD pipeline (Build & Release)
│
├── assets/
│   ├── fonts/                         # Custom Poppins font family
│   └── images/                        # Brand icons and visual illustrations
│
├── docs/                              # Hosted web & compliance pages (GitHub Pages)
│   ├── data-deletion.html             # User data deletion request instructions
│   ├── index.html                     # KharchMate landing page
│   ├── privacy.html                   # Privacy Policy webpage
│   ├── support.html                   # Help & support contact portal
│   └── terms.html                     # Terms of Service webpage
│
├── lib/
│   ├── main.dart                      # Default production entry point
│   ├── main_dev.dart                  # Development entry point (Test AdMob IDs)
│   ├── main_staging.dart              # Staging entry point
│   ├── main_prod.dart                 # Production entry point (Live AdMob IDs)
│   │
│   ├── database/                      # SQLite persistence layer
│   │   ├── app_database.dart          # Database open, close & migration orchestration
│   │   ├── database_constants.dart    # Table and column constant definitions
│   │   ├── daos/                      # Data Access Objects
│   │   │   ├── budget_dao.dart        # Monthly and category budget limits
│   │   │   ├── category_dao.dart      # Category querying, custom categories & counts
│   │   │   ├── payment_method_dao.dart# Payment method querying and defaults
│   │   │   ├── transaction_dao.dart   # Transaction CRUD, multi-filters & trend analytics
│   │   │   └── user_dao.dart          # Profile persistence (name, email, dark mode)
│   │   └── migrations/                # Versioned schema migrations
│   │       ├── database_migration.dart# Abstract migration contract & MigrationRunner
│   │       └── migration_v1.dart      # V1 schema creation and default seeding
│   │
│   ├── di/                            # Dependency Injection
│   │   └── service_locator.dart       # Service locator registrations (GetIt)
│   │
│   ├── enum/                          # Financial & payment enumerations
│   │   ├── payment_mode.dart          # UPI, Card, Bank, Cash
│   │   └── payment_type.dart          # Credit, Debit
│   │
│   ├── environment/                   # Environment & Configuration
│   │   └── app_environment.dart       # AppEnvironment enum & AppConfig with AdMob keys
│   │
│   ├── helper/                        # Helper utilities
│   │   └── validation_helper.dart     # Input validation rules (email regex, non-empty)
│   │
│   ├── models/                        # Domain models
│   │   ├── budget_item.dart           # Budget limit entity
│   │   ├── category.dart              # Category entity with smart icon & color resolvers
│   │   ├── financial_summary.dart     # Monthly financial summary & trend models
│   │   ├── payment_method.dart        # Payment method entity
│   │   ├── transaction_item.dart      # Transaction entity
│   │   └── user_profile.dart          # User profile model (name, email, currency)
│   │
│   ├── resources/                     # Design tokens & resource constants
│   │   ├── app_colors.dart            # Palettes, gradients, finance colors
│   │   ├── app_dimension.dart         # Dimensional tokens & spacing
│   │   ├── app_font.dart              # Font families
│   │   ├── app_icons.dart             # Asset icons
│   │   └── resources.dart             # Barrel export
│   │
│   ├── router/                        # Routing & navigation
│   │   ├── app_router.dart            # GoRouter configuration & route bindings
│   │   └── app_routes.dart            # AppRoutes enum, paths & names
│   │
│   ├── services/                      # Core business services
│   │   ├── ad_service.dart            # Google AdMob banners, rewarded ads & ad-free pass
│   │   ├── database_service.dart      # Unified SQLite API & Data Deletion facade
│   │   └── secure_storage_service.dart# Encrypted key-value persistence
│   │
│   ├── theme/                         # Theming & typography
│   │   ├── custom_text_style.dart     # Material TextTheme with Poppins
│   │   └── themes.dart                # Core theme definitions (Material 3)
│   │
│   ├── ui/                            # Feature screens & views
│   │   ├── categories/                # Category listing and custom category creation
│   │   ├── dashboard/                 # Financial summary cards, pie chart & month overview
│   │   ├── onboarding/                # Welcome tutorial & user name/email setup
│   │   ├── reports/                   # Reports screen (Overview, Category, Trends tabs)
│   │   ├── settings/                  # Settings, User Profile, Help/Support, Privacy, Terms
│   │   ├── splash/                    # Animated splash screen
│   │   └── transaction/               # Transactions list (multi-filter), details & add
│   │
│   └── widgets/                       # Reusable UI components
│       ├── app_loader.dart            # Standard loading overlay
│       ├── app_text_button.dart       # Gradient action buttons
│       ├── app_textformfield.dart     # Form inputs with prefix icons & validation
│       ├── common_listview.dart       # Scrollable lists with empty state handling
│       ├── dashboard_banner_ad_widget.dart # AdMob banner widget with ad-free check
│       └── month_year_picker_sheet.dart# Bottom sheet for month-year selection
│
├── android/                           # Android native configuration
│   ├── app/build.gradle.kts           # Gradle configuration, release signing & applicationId
│   └── app/proguard-rules.pro         # ProGuard / R8 rules for SQLite, AdMob & plugins
│
├── ARCHITECTURE.md                    # Technical architecture & design specification
├── antigravity.md                     # AI Assistant Blueprint & Knowledge Base
└── pubspec.yaml                       # Dependencies, fonts & asset bindings
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`^3.47.2` or later)
- Dart SDK (`^3.13.2`)
- Android Studio / Xcode for device emulation
- Java 17+ (Java 21 recommended for Android Gradle plugin)

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

### Running with Environments

KharchMate provides dedicated entry points for development, staging, and production:

- **Development** (uses official Google test AdMob IDs to prevent ad policy strikes):
  ```bash
  flutter run -t lib/main_dev.dart
  ```

- **Staging**:
  ```bash
  flutter run -t lib/main_staging.dart
  ```

- **Production** (uses live Google AdMob production keys):
  ```bash
  flutter run -t lib/main_prod.dart
  ```

### Static Analysis

Ensure code quality and style compliance:
```bash
flutter analyze
```

### Building for Release

- **Android App Bundle (`.aab`)**:
  ```bash
  flutter build appbundle --release -t lib/main_prod.dart
  ```

- **Android APK (`.apk`)**:
  ```bash
  flutter build apk --release -t lib/main_prod.dart
  ```

---

## 🤖 CI/CD Pipeline

KharchMate features an automated GitHub Actions workflow (`.github/workflows/deploy.yml`):
- Triggers on pushes and PRs to `main` branch, or via manual dispatch.
- Verifies code quality with `flutter analyze`.
- Injects release signing credentials from GitHub Secrets (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`).
- Builds signed **Android App Bundle (.aab)** and **Android APK (.apk)**.
- Automatically creates a GitHub Release tagged with the version from `pubspec.yaml` and uploads release artifacts.

---

## 🌐 Web Documentation & Legal

KharchMate hosts public compliance and documentation pages under `docs/`:
- **Landing Page**: [KharchMate Home](https://nipuldaki.github.io/KharchMate/)
- **Privacy Policy**: [Privacy Policy](https://nipuldaki.github.io/KharchMate/privacy.html)
- **Terms of Service**: [Terms of Service](https://nipuldaki.github.io/KharchMate/terms.html)
- **Help & Support**: [Help & Support](https://nipuldaki.github.io/KharchMate/support.html)
- **Data Deletion Policy**: [Data Deletion Request](https://nipuldaki.github.io/KharchMate/data-deletion.html)

---

## 📄 License

This project is licensed under the MIT License.

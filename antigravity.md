# KharchMate - Antigravity Knowledge Base & Project Blueprint 🚀

> **Note for AI Assistant (Antigravity):** Refer to this document for instant context on the KharchMate codebase. Avoid re-reading or scanning the entire project or resource directories (`assets/images/`, `assets/fonts/`) unless specifically requested.

---

## 📌 Project Overview
- **App Name:** KharchMate
- **Platform:** Flutter (Android & iOS)
- **SDK Target:** Flutter `>=3.47.2`, Dart `>=3.13.2`
- **Core Purpose:** 100% Offline-first personal expense tracker & budget management app. No cloud dependencies or mandatory external accounts.
- **Primary Package Architecture:** Clean layered & feature-modular design.

---

## 🛠️ Tech Stack & Key Libraries

| Dependency | Version / Source | Purpose |
| :--- | :--- | :--- |
| `flutter` | SDK | Framework & Material 3 UI |
| `go_router` | `^14.8.1` | Declarative routing, deep-links, parameter passing |
| `sqflite` | `^2.4.2` | Local relational SQLite database on device |
| `sqflite_common_ffi` | `^2.3.4+4` | Desktop/test SQLite engine for fast in-memory testing |
| `flutter_secure_storage`| `^9.2.4` | Encrypted key-value persistence (tokens, flags) |
| `get_it` / `service_locator` | Internal singleton | DI locator (`lib/di/service_locator.dart`) |
| `intl` | `^0.20.2` | Number, currency, and date formatting |

---

## 🎨 Design System & Resources

- **Brand Colors** (`lib/resources/app_colors.dart`):
  - Primary: Warm Orange (`#FF7A00` / `0xFFFF7A00`), Primary Dark (`#E65100`), Primary Light (`#FFB74D`)
  - Background: Warm tint (`#FFF3E0`) and White (`#FFFFFF`)
  - Linear Gradient: `AppColors.linerGradient` (`#E65100` ➔ `#FF7A00` ➔ `#FF9800`)
  - Finance Badges: Income (`#1A6C45`), Expense (`#F44336`), Savings/Balance (`#00897B`)
- **Dimensions** (`lib/resources/app_dimension.dart`):
  - Scaled spacing constants: `AppDimens.dimen0` through `AppDimens.dimen210`
- **Typography** (`lib/resources/app_font.dart`, `lib/theme/custom_text_style.dart`):
  - Primary Font: **Poppins** (Weights: 100, 300, 400, 500, 600, 700)
- **Theme** (`lib/theme/themes.dart`):
  - Material 3 enabled (`useMaterial3: true`), custom `AppBarTheme` (0 elevation), custom `TextSelectionThemeData`.
- ⚠️ **Constraint:** Never read or modify font files (`assets/fonts/`) or image files (`assets/images/`) as they are static binary assets.

---

## 🗄️ Database & Persistence Architecture

### Database Engine (`lib/database/app_database.dart`)
- Unified SQLite manager with singleton instance registered in `serviceLocator<AppDatabase>()`.
- Default database file: `kharch_mate.db`.
- In-memory database supported for tests: `customPath: inMemoryDatabasePath`.

### Database Service Facade (`lib/services/database_service.dart`)
- High-level API consumed by UI screens (`serviceLocator<DatabaseService>()`).
- Directly wraps and delegates calls to DAOs:
  - `_userDao`, `_categoryDao`, `_paymentMethodDao`, `_transactionDao`, `_budgetDao`.

### Migrations Engine (`lib/database/migrations/`)
- Base class: `DatabaseMigration` (`version`, `description`, `up()`, `down()`).
- Runner: `MigrationRunner` executes pending migrations atomically in a transaction and tracks them in `schema_migrations`.
- **Migration V1** (`migration_v1.dart`):
  - `users`: `id`, `name`, `email`, `currency_code`, `currency_symbol`, `is_dark_mode`, `created_at`, `updated_at`
  - `categories`: `id`, `name`, `type` (expense/income/both), `icon`, `color`, `is_default`, `created_at`
  - `payment_methods`: `id`, `name`, `type`, `icon`, `is_default`, `created_at`
  - `transactions`: `id`, `title`, `amount`, `type`, `category_id`, `payment_method_id`, `payment_method_name`, `date`, `note`, `receipt_image_path`, `created_at`, `updated_at` (Indexes on `date`, `type`, `category_id`)
  - `budgets`: `id`, `category_id`, `is_overall`, `amount_limit`, `month`, `year`, `created_at`, `updated_at` (Index on `month, year`)
  - Pre-seeded Categories: Rent, Food, Transport, Shopping (Expense); Salary, Bonus (Income).
  - Pre-seeded Payment Methods: Cash, HDFC Bank, UPI, Credit Card, Debit Card.

---

## 🧭 Routes Map (`lib/router/app_routes.dart` & `app_router.dart`)

| Route Enum | Path | Screen Widget | Description |
| :--- | :--- | :--- | :--- |
| `AppRoutes.root` | `/` | Redirects to `/splash` | Root entry point |
| `AppRoutes.splash` | `/splash` | `SplashScreen` | Checks `hasUser()` -> dashboard or welcome |
| `AppRoutes.welcome` | `/welcome` | `WelcomeScreen` | 3-slide auto-advancing tutorial carousel |
| `AppRoutes.userName` | `/user-name` | `UserNameScreen` | Name & Email input with format validation |
| `AppRoutes.dashboard`| `/dashboard` | `DashboardScreen` | Summary cards, month-year picker, recent list |
| `AppRoutes.transaction`| `/transaction` | `TransactionsScreen` | Searchable/filterable transactions list |
| `AppRoutes.addTransaction` | `/add-transaction` | `AddTransactionScreen` | Record or edit an expense or income |
| `AppRoutes.transactionDetails`| `/transaction-details` | `TransactionDetailsScreen` | Detailed view with delete action |
| `AppRoutes.report` | `/report` | Planned | Visual trend analytics and charts |
| `AppRoutes.budget` | `/budget` | Planned | Budget limits and alerts management |
| `AppRoutes.settings` | `/settings` | `SettingsScreen` | Profile, currency switcher, dark mode, logout |
| `AppRoutes.categories` | `/categories` | `CategoriesScreen` | View expense/income category tabs |
| `AppRoutes.addCategory`| `/add-category` | `AddCategoryScreen` | Create custom category with color & icon |

---

## 🧱 Key Components & Domain Models

### Domain Models (`lib/models/`)
- **`UserProfile`** (`user_profile.dart`): `name`, `email` (nullable), `currencyCode`, `currencySymbol`, `isDarkMode`, `initials` getter.
- **`TransactionItem`** (`transaction_item.dart`): `title`, `amount`, `type` (`TransactionType.expense` / `income`), `categoryId`, `categoryName`, `categoryIcon`, `categoryColor`, `paymentMethodName`, `date`, `note`, `receiptImagePath`.
- **`CategoryModel`** (`category.dart`): `name`, `type` (`CategoryType`), `icon`, `color`, `isDefault`.
- **`BudgetItem`** (`budget_item.dart`): `amountLimit`, `month`, `year`, `categoryId`, `isOverall`, `spentAmount`, `isExceeded`, `isNearLimit`.
- **`FinancialSummary`** (`financial_summary.dart`): `totalIncome`, `totalExpense`, `totalBalance`, `savings`, `categoryBreakdown`.

### Reusable Widgets (`lib/widgets/`)
- **`AppTextFormField`**: Label, hint, prefix/suffix icons, validation error display, reactive dismiss on tap outside.
- **`AppTextButton`**: Pill-shaped button styled with brand linear gradient (`AppColors.linerGradient`).
- **`AppLoader`**: Centered loading box overlay with `CircularProgressIndicator`.
- **`CommonListView`**: Reusable scrollable view with pull-to-refresh and empty-state placeholders.
- **`MonthYearPickerSheet`**: Modal bottom sheet with horizontal year navigation and 12-month selector grid.

### Validation Helpers (`lib/helper/validation_helper.dart`)
- `ValidationHelper.blank(value, fieldName)`: Non-empty string check.
- `ValidationHelper.email(value)`: Strict regex validation (`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`).

---

## 🧪 Testing Guidelines & Conventions

### Running Tests & Lint
```bash
# Run all unit and widget tests
flutter test

# Run static analysis
flutter analyze
```

### Writing Widget Tests with SQLite
- Initialize FFI in `setUpAll`:
  ```dart
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  ```
- Use `inMemoryDatabasePath` inside `setUp()` for isolated database testing.
- When triggering asynchronous database queries from widget event handlers, use `tester.pump()` and `tester.runAsync(() async { await Future.delayed(...); })` to allow SQLite background isolate operations to resolve.
- Avoid calling `pumpAndSettle()` when an infinite animation is active (e.g. `AppLoader`'s `CircularProgressIndicator`).

---

## 📋 Quick Code Rules & Conventions
1. **Never hardcode hex colors or pixel dimensions:** Always reference `AppColors.*` and `AppDimens.*`.
2. **Database calls:** Route all queries through `serviceLocator<DatabaseService>()`.
3. **Navigation:** Always use `context.go(AppRoutes.<route>.path)` or `context.push(...)`.
4. **Validation:** Use `ValidationHelper` for form input checks.
5. **Clean tests:** Always ensure `flutter analyze` has 0 issues and `flutter test` passes 100% after modifications.

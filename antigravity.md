# KharchMate - Antigravity Knowledge Base & Project Blueprint 🚀

> **Note for AI Assistant (Antigravity):** Refer to this document for instant context on the KharchMate codebase. Avoid re-reading or scanning the entire project or resource directories (`assets/images/`, `assets/fonts/`) unless specifically requested.

---

## 📌 Project Overview
- **App Name:** KharchMate
- **Android Application ID / Namespace:** `com.nipul.kharchmate`
- **Platform:** Flutter (Android & iOS)
- **SDK Target:** Flutter `>=3.47.2`, Dart `>=3.13.2`
- **Core Purpose:** 100% Offline-first personal expense tracker & budget management app with visual analytics, zero cloud lock-in, and full data privacy.
- **Primary Package Architecture:** Clean layered & feature-modular design.

---

## 🛠️ Tech Stack & Key Libraries

| Dependency | Version | Purpose |
| :--- | :--- | :--- |
| `flutter` | SDK | Framework & Material 3 UI |
| `go_router` | `^18.0.1` | Declarative routing, parameter passing, 17 defined routes |
| `sqflite` | `^2.4.4` | Local relational SQLite database engine |
| `path` | `^1.9.1` | File system path operations |
| `flutter_secure_storage`| `^11.1.1` | Encrypted key-value persistence (Ad-free timestamp, tokens) |
| `get_it` | `^9.2.1` | Service locator / DI (`lib/di/service_locator.dart`) |
| `intl` | `^0.20.3` | Number, currency, and date formatting |
| `fl_chart` | `^1.2.0` | Interactive charts (Pie/Donut charts & Monthly trends) |
| `google_mobile_ads` | `^9.1.0` | Google AdMob Banners & Rewarded Video Ads |
| `package_info_plus` | `^10.2.1` | Dynamic app version and build number retrieval |
| `url_launcher` | `^6.3.2` | External URL launching (Support links, Google Play review) |
| `flutter_lints` | `^6.0.0` | Static analysis & coding conventions |
| `flutter_launcher_icons`| `^0.14.4`| Automated app icon generation |

---

## 🤖 Environment Configuration & Entry Points (`lib/environment/`)

KharchMate provides environment isolation across Development, Staging, and Production:

- **`AppEnvironment`**: Enum (`development`, `staging`, `production`).
- **`AppConfig`**: Singleton holding environment metadata and dynamic AdMob keys.
- **Entry Points**:
  - `lib/main_dev.dart`: Development mode (`AppEnvironment.development`). Automatically loads Google official test AdMob IDs to prevent ad policy strikes.
  - `lib/main_staging.dart`: Staging mode (`AppEnvironment.staging`).
  - `lib/main_prod.dart`: Production release mode (`AppEnvironment.production`). Uses live AdMob App & Ad Unit IDs.
  - `lib/main.dart`: Default entry point (defaults to production).
- **AdMob Key Resolution**:
  - `prodAndroidAppId`: `ca-app-pub-9185976312211555~7770386179`
  - `prodIosAppId`: `ca-app-pub-9185976312211555~5536948384`
  - `prodAndroidBannerId`: `ca-app-pub-9185976312211555/2800683417`
  - `prodAndroidRewardedId`: `ca-app-pub-9185976312211555/7141674098`
  - Automated fallback to Google official test IDs (`ca-app-pub-3940256099942544/...`) in non-production environments.

---

## 🧭 Complete Routes Map (`lib/router/app_routes.dart` & `app_router.dart`)

| Route Enum | Path | Screen Widget | Description |
| :--- | :--- | :--- | :--- |
| `AppRoutes.root` | `/` | Redirect to `/splash` | Root entry redirection |
| `AppRoutes.splash` | `/splash` | `SplashScreen` | Animated splash checking `hasUser()` -> dashboard or welcome |
| `AppRoutes.welcome` | `/welcome` | `WelcomeScreen` | 3-slide auto-advancing tutorial walkthrough |
| `AppRoutes.userName` | `/user-name` | `UserNameScreen` | Name & Email input with regex validation |
| `AppRoutes.dashboard`| `/dashboard` | `DashboardScreen` | Summary cards, pie chart, month picker, recent list |
| `AppRoutes.transaction`| `/transaction` | `TransactionsScreen` | Multi-criteria filterable & searchable transaction list |
| `AppRoutes.addTransaction` | `/add-transaction` | `AddTransactionScreen` | Record or edit an expense or income entry |
| `AppRoutes.transactionDetails`| `/transaction-details` | `TransactionDetailsScreen` | Detailed view with receipt path & delete action |
| `AppRoutes.report` | `/report` | `ReportsScreen` | Visual analytics: Overview, Category breakdown & Trends |
| `AppRoutes.budget` | `/budget` | Planned | Budget limits and alerts management |
| `AppRoutes.settings` | `/settings` | `SettingsScreen` | Profile card, ad-free pass, currency, review, data reset |
| `AppRoutes.categories` | `/categories` | `CategoriesScreen` | View expense/income category tabs with badges |
| `AppRoutes.addCategory`| `/add-category` | `AddCategoryScreen` | Create custom category with color & icon picker |
| `AppRoutes.privacyPolicy` | `/privacy-policy` | `PrivacyPolicyScreen` | In-app offline Privacy Policy viewer |
| `AppRoutes.termsOfUse` | `/terms-of-use` | `TermsScreen` | In-app offline Terms of Service viewer |
| `AppRoutes.helpSupport` | `/help-support` | `HelpSupportScreen` | FAQs, support email & web documentation portal |
| `AppRoutes.userProfile` | `/user-profile` | `UserProfileScreen` | View/edit full name & email, view account stats |

---

## ⚙️ Core Services & Persistence Architecture

### 1. Database Service Facade (`lib/services/database_service.dart`)
- Singleton registered in `serviceLocator<DatabaseService>()`.
- **Reactive Streams**:
  - `Stream<void> onTransactionChanged`: Auto-refreshes Dashboard, Transactions, and Reports on CRUD events.
  - `Stream<UserProfile> onUserProfileChanged`: Auto-refreshes greeting, currency, and profile headers.
- **Key Operations**:
  - `getUserProfile()`, `saveUserName(name, {email})`, `updateUserProfile({name, email})`, `updateDarkMode(bool)`, `deleteUser()`.
  - `deleteMyData()`: Atomic transaction wiping all transactions, budgets, custom categories, custom payment methods, and user profile while preserving seed records.
  - `getTransactions({type, searchQuery, date, startDate, endDate, month, year, categoryId, limit, offset})`: Multi-criteria filtering.
  - `getMonthlySummary(month, year)`: Net balance, total income, total expense, savings rate, category breakdown.
  - `getMonthlyTrends(year, {count = 6, endMonth})`: 6-month historical income vs expense series.

### 2. Monetization & Reward Service (`lib/services/ad_service.dart`)
- Singleton registered in `serviceLocator<AdService>()`.
- **Google AdMob Integration**:
  - `init()`: Initializes MobileAds SDK and loads stored ad-free status.
  - `loadBannerAd(...)` & `disposeBannerAd()`: Handles banner ads with error recovery.
  - `loadRewardedAd()` & `showRewardedAd(...)`: Preloads and shows rewarded video ads.
- **3-Day Ad-Free Pass Mechanics**:
  - `grantAdFreePass({Duration duration = const Duration(days: 3)})`: Appends 3 days to current expiration.
  - `isAdFree`: Returns boolean indicating if user currently has an active ad-free pass.
  - `remainingAdFreeText`: Human-readable remaining time (e.g., "2 days 18 hrs left").
  - `Stream<bool> onAdFreeChanged`: Emits state change to suppress banner ads application-wide.
  - Encrypted storage under `ad_free_until_timestamp` via `SecureStorageService`.

### 3. Secure Storage Service (`lib/services/secure_storage_service.dart`)
- Encrypted key-value storage powered by `FlutterSecureStorage`.
- Handles sensitive application flags, tokens, and ad-free expiration timestamps.

---

## 🎨 Design System & Resources

- **Brand Colors** (`lib/resources/app_colors.dart`):
  - Primary: Warm Orange (`#FF7A00`), Primary Dark (`#E65100`), Primary Light (`#FFB74D`)
  - Background: Warm Tint (`#FFF3E0`) and Pure White (`#FFFFFF`)
  - Gradient: `AppColors.linerGradient` (`#E65100` ➔ `#FF7A00` ➔ `#FF9800`)
  - Finance Badges: Income (`#1A6C45`), Expense (`#F44336`), Savings/Balance (`#00897B`)
- **Typography** (`lib/resources/app_font.dart`, `lib/theme/custom_text_style.dart`):
  - Exclusive font family: **Poppins** (Weights: 100, 300, 400, 500, 600, 700).
- **Dimensions** (`lib/resources/app_dimension.dart`):
  - Standard spacing tokens: `AppDimens.dimen0` through `AppDimens.dimen210`.
- ⚠️ **Constraint:** Never edit or read font files (`assets/fonts/`) or image binaries (`assets/images/`).

---

## 📦 Native Platform, ProGuard & CI/CD Pipeline

- **Application ID / Package**: `com.nipul.kharchmate`
- **Release Signing**: Configured in `android/app/build.gradle.kts` via `android/key.properties`.
- **ProGuard / R8 Rules (`android/app/proguard-rules.pro`)**:
  - SQLite FFI, Google Mobile Ads SDK, and Flutter plugin bindings preserved.
- **GitHub Actions Workflow (`.github/workflows/deploy.yml`)**:
  - Triggered on push/PR to `main` branch or manual dispatch.
  - Installs Java 21 Temurin and Flutter 3.47.2.
  - Runs `flutter analyze` for static code verification.
  - Injects release keystore from `KEYSTORE_BASE64` secret.
  - Builds signed Android App Bundle (`app-release.aab`) and APK (`app-release.apk`).
  - Publishes GitHub Releases with version tags and downloads.
- **Hosted Web Compliance (`docs/`)**:
  - Public pages: `index.html`, `privacy.html`, `terms.html`, `support.html`, `data-deletion.html`.

---

## 📋 Quick Code Rules & Conventions
1. **Never hardcode hex colors or pixel dimensions:** Always reference `AppColors.*` and `AppDimens.*`.
2. **Database calls:** Route all queries through `serviceLocator<DatabaseService>()`.
3. **Ad interactions:** Always query `serviceLocator<AdService>()` and respect `isAdFree`.
4. **Navigation:** Always use `context.go(AppRoutes.<route>.path)` or `context.push(...)`.
5. **Validation:** Always use `ValidationHelper` for form input checks.
6. **Code Quality:** Ensure `flutter analyze` has 0 warnings or errors after modifications.

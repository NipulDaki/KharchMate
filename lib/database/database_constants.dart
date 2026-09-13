/// Database table and column constants for KharchMate SQLite database.
class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'kharch_mate.db';
  static const int databaseVersion = 1;

  // Tables
  static const String tableMigrations = 'schema_migrations';
  static const String tableUsers = 'users';
  static const String tableCategories = 'categories';
  static const String tablePaymentMethods = 'payment_methods';
  static const String tableTransactions = 'transactions';
  static const String tableBudgets = 'budgets';

  // schema_migrations columns
  static const String colMigrationVersion = 'version';
  static const String colMigrationDescription = 'description';
  static const String colMigrationAppliedAt = 'applied_at';

  // users columns
  static const String colUserId = 'id';
  static const String colUserName = 'name';
  static const String colUserEmail = 'email';
  static const String colUserCurrencyCode = 'currency_code';
  static const String colUserCurrencySymbol = 'currency_symbol';
  static const String colUserIsDarkMode = 'is_dark_mode';
  static const String colUserCreatedAt = 'created_at';
  static const String colUserUpdatedAt = 'updated_at';

  // categories columns
  static const String colCategoryId = 'id';
  static const String colCategoryName = 'name';
  static const String colCategoryType = 'type'; // 'expense' | 'income' | 'both'
  static const String colCategoryIcon = 'icon';
  static const String colCategoryColor = 'color';
  static const String colCategoryIsDefault = 'is_default';
  static const String colCategoryCreatedAt = 'created_at';

  // payment_methods columns
  static const String colPaymentMethodId = 'id';
  static const String colPaymentMethodName = 'name';
  static const String colPaymentMethodType = 'type'; // 'cash' | 'bank' | 'card' | 'upi'
  static const String colPaymentMethodIcon = 'icon';
  static const String colPaymentMethodIsDefault = 'is_default';
  static const String colPaymentMethodCreatedAt = 'created_at';

  // transactions columns
  static const String colTransactionId = 'id';
  static const String colTransactionTitle = 'title';
  static const String colTransactionAmount = 'amount';
  static const String colTransactionType = 'type'; // 'expense' | 'income'
  static const String colTransactionCategoryId = 'category_id';
  static const String colTransactionPaymentMethodId = 'payment_method_id';
  static const String colTransactionPaymentMethodName = 'payment_method_name';
  static const String colTransactionDate = 'date'; // ISO 8601 string
  static const String colTransactionNote = 'note';
  static const String colTransactionReceiptPath = 'receipt_image_path';
  static const String colTransactionCreatedAt = 'created_at';
  static const String colTransactionUpdatedAt = 'updated_at';

  // budgets columns
  static const String colBudgetId = 'id';
  static const String colBudgetCategoryId = 'category_id'; // null if overall monthly budget
  static const String colBudgetIsOverall = 'is_overall'; // 1 for overall monthly budget, 0 for category
  static const String colBudgetAmountLimit = 'amount_limit';
  static const String colBudgetMonth = 'month'; // 1 to 12
  static const String colBudgetYear = 'year';
  static const String colBudgetCreatedAt = 'created_at';
  static const String colBudgetUpdatedAt = 'updated_at';
}

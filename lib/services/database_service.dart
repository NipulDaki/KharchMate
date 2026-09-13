import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/database/daos/budget_dao.dart';
import 'package:kharch_mate/database/daos/category_dao.dart';
import 'package:kharch_mate/database/daos/payment_method_dao.dart';
import 'package:kharch_mate/database/daos/transaction_dao.dart';
import 'package:kharch_mate/database/daos/user_dao.dart';
import 'package:kharch_mate/models/budget_item.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:kharch_mate/models/financial_summary.dart';
import 'package:kharch_mate/models/payment_method.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:kharch_mate/models/user_profile.dart';

/// Unified SQLite Database Service for KharchMate.
///
/// Encapsulates all persistence logic, DAOs, schema upgrades, and domain queries.
class DatabaseService {
  final AppDatabase _appDatabase;
  late final UserDao _userDao;
  late final CategoryDao _categoryDao;
  late final PaymentMethodDao _paymentMethodDao;
  late final TransactionDao _transactionDao;
  late final BudgetDao _budgetDao;

  DatabaseService({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase() {
    _userDao = UserDao(appDb: _appDatabase);
    _categoryDao = CategoryDao(appDb: _appDatabase);
    _paymentMethodDao = PaymentMethodDao(appDb: _appDatabase);
    _transactionDao = TransactionDao(appDb: _appDatabase);
    _budgetDao = BudgetDao(appDb: _appDatabase);
  }

  /// Initialize database connection and run pending migrations.
  Future<void> init({String? customPath}) async {
    await _appDatabase.init(customPath: customPath);
  }

  /// Close database connection.
  Future<void> close() async {
    await _appDatabase.close();
  }

  /// Resets database by rolling back all migrations and re-running them.
  Future<void> resetDatabase() async {
    await _appDatabase.resetDatabase();
  }

  // ==========================================
  // USER PROFILE OPERATIONS
  // ==========================================

  Future<UserProfile?> getUserProfile() => _userDao.getUserProfile();

  Future<bool> hasUser() => _userDao.hasUser();

  Future<UserProfile> saveUserProfile(UserProfile profile) =>
      _userDao.saveUserProfile(profile);

  Future<UserProfile> saveUserName(String name) => _userDao.saveUserName(name);

  Future<void> updateDarkMode(bool isDarkMode) =>
      _userDao.updateDarkMode(isDarkMode);

  Future<void> deleteUser() => _userDao.deleteUser();

  // ==========================================
  // CATEGORY OPERATIONS
  // ==========================================

  Future<List<CategoryModel>> getAllCategories() =>
      _categoryDao.getAllCategories();

  Future<List<CategoryModel>> getExpenseCategories() =>
      _categoryDao.getCategoriesByType(CategoryType.expense);

  Future<List<CategoryModel>> getIncomeCategories() =>
      _categoryDao.getCategoriesByType(CategoryType.income);

  Future<CategoryModel?> getCategoryById(int id) =>
      _categoryDao.getCategoryById(id);

  Future<CategoryModel> insertCategory(CategoryModel category) =>
      _categoryDao.insertCategory(category);

  Future<int> updateCategory(CategoryModel category) =>
      _categoryDao.updateCategory(category);

  Future<void> ensurePredefinedCategories() =>
      _categoryDao.ensurePredefinedCategories();

  Future<int> getTransactionCountForCategory(int categoryId) =>
      _categoryDao.getTransactionCountForCategory(categoryId);

  Future<int> deleteCategory(int id) => _categoryDao.deleteCategory(id);

  // ==========================================
  // PAYMENT METHOD OPERATIONS
  // ==========================================

  Future<List<PaymentMethodModel>> getPaymentMethods() =>
      _paymentMethodDao.getAll();

  Future<PaymentMethodModel?> getPaymentMethodById(int id) =>
      _paymentMethodDao.getById(id);

  Future<PaymentMethodModel> insertPaymentMethod(PaymentMethodModel method) =>
      _paymentMethodDao.insert(method);

  // ==========================================
  // TRANSACTION OPERATIONS
  // ==========================================

  Future<TransactionItem> insertTransaction(TransactionItem transaction) =>
      _transactionDao.insertTransaction(transaction);

  Future<TransactionItem?> updateTransaction(TransactionItem transaction) =>
      _transactionDao.updateTransaction(transaction);

  Future<int> deleteTransaction(int id) =>
      _transactionDao.deleteTransaction(id);

  Future<TransactionItem?> getTransactionById(int id) =>
      _transactionDao.getTransactionById(id);

  Future<List<TransactionItem>> getRecentTransactions({int limit = 5}) =>
      _transactionDao.getRecentTransactions(limit: limit);

  Future<List<TransactionItem>> getTransactions({
    TransactionType? type,
    String? searchQuery,
    int? month,
    int? year,
    int? categoryId,
    int? limit,
    int? offset,
  }) =>
      _transactionDao.getTransactions(
        type: type,
        searchQuery: searchQuery,
        month: month,
        year: year,
        categoryId: categoryId,
        limit: limit,
        offset: offset,
      );

  // ==========================================
  // FINANCIAL SUMMARIES & ANALYTICS
  // ==========================================

  Future<FinancialSummary> getMonthlySummary(int month, int year) =>
      _transactionDao.getMonthlySummary(month, year);

  Future<List<CategorySpending>> getCategorySpending(int month, int year) =>
      _transactionDao.getCategorySpending(month, year);

  Future<List<MonthlyTrend>> getMonthlyTrends(
    int year, {
    int count = 6,
    int? endMonth,
  }) =>
      _transactionDao.getMonthlyTrends(year, count: count, endMonth: endMonth);

  // ==========================================
  // BUDGET OPERATIONS
  // ==========================================

  Future<BudgetItem?> getOverallBudget(int month, int year) =>
      _budgetDao.getOverallBudget(month, year);

  Future<BudgetItem> setOverallBudget({
    required double amountLimit,
    required int month,
    required int year,
  }) =>
      _budgetDao.setOverallBudget(amountLimit, month, year);

  Future<List<BudgetItem>> getCategoryBudgets(int month, int year) =>
      _budgetDao.getCategoryBudgets(month, year);

  Future<BudgetItem> setCategoryBudget({
    required int categoryId,
    required double amountLimit,
    required int month,
    required int year,
  }) =>
      _budgetDao.setCategoryBudget(
        categoryId: categoryId,
        amountLimit: amountLimit,
        month: month,
        year: year,
      );

  Future<int> deleteBudget(int id) => _budgetDao.deleteBudget(id);

  Future<String?> getBudgetAlert(int month, int year) =>
      _budgetDao.getBudgetAlert(month, year);
}

import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/database/database_constants.dart';
import 'package:kharch_mate/models/budget_item.dart';
import 'package:sqflite/sqflite.dart';

class BudgetDao {
  final AppDatabase appDatabase;

  BudgetDao({AppDatabase? appDb}) : appDatabase = appDb ?? AppDatabase();

  Database get _db => appDatabase.db;

  /// Retrieves the overall monthly budget for a given month & year.
  Future<BudgetItem?> getOverallBudget(int month, int year) async {
    final results = await _db.query(
      DatabaseConstants.tableBudgets,
      where:
          '${DatabaseConstants.colBudgetIsOverall} = 1 AND ${DatabaseConstants.colBudgetMonth} = ? AND ${DatabaseConstants.colBudgetYear} = ?',
      whereArgs: [month, year],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final item = BudgetItem.fromMap(results.first);

    // Calculate total spent across all expenses in that month
    final monthStr = month.toString().padLeft(2, '0');
    final dateFilter = '$year-$monthStr';

    final spentResult = await _db.rawQuery(
      '''
      SELECT COALESCE(SUM(${DatabaseConstants.colTransactionAmount}), 0.0) as total_spent
      FROM ${DatabaseConstants.tableTransactions}
      WHERE ${DatabaseConstants.colTransactionType} = 'expense'
        AND strftime('%Y-%m', ${DatabaseConstants.colTransactionDate}) = ?
    ''',
      [dateFilter],
    );

    final totalSpent =
        (spentResult.first['total_spent'] as num?)?.toDouble() ?? 0.0;

    return item.copyWith(spentAmount: totalSpent);
  }

  /// Sets or updates the overall monthly budget.
  Future<BudgetItem> setOverallBudget(
    double amountLimit,
    int month,
    int year,
  ) async {
    final now = DateTime.now();
    final existing = await _db.query(
      DatabaseConstants.tableBudgets,
      where:
          '${DatabaseConstants.colBudgetIsOverall} = 1 AND ${DatabaseConstants.colBudgetMonth} = ? AND ${DatabaseConstants.colBudgetYear} = ?',
      whereArgs: [month, year],
      limit: 1,
    );

    if (existing.isEmpty) {
      final id = await _db.insert(
        DatabaseConstants.tableBudgets,
        {
          DatabaseConstants.colBudgetCategoryId: null,
          DatabaseConstants.colBudgetIsOverall: 1,
          DatabaseConstants.colBudgetAmountLimit: amountLimit,
          DatabaseConstants.colBudgetMonth: month,
          DatabaseConstants.colBudgetYear: year,
          DatabaseConstants.colBudgetCreatedAt: now.toIso8601String(),
          DatabaseConstants.colBudgetUpdatedAt: now.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return (await getOverallBudget(month, year)) ??
          BudgetItem(
            id: id,
            isOverall: true,
            amountLimit: amountLimit,
            month: month,
            year: year,
            createdAt: now,
            updatedAt: now,
          );
    } else {
      final existingId = existing.first[DatabaseConstants.colBudgetId] as int;
      await _db.update(
        DatabaseConstants.tableBudgets,
        {
          DatabaseConstants.colBudgetAmountLimit: amountLimit,
          DatabaseConstants.colBudgetUpdatedAt: now.toIso8601String(),
        },
        where: '${DatabaseConstants.colBudgetId} = ?',
        whereArgs: [existingId],
      );

      return (await getOverallBudget(month, year))!;
    }
  }

  /// Retrieves all category budgets for the specified month & year,
  /// joined with category details and calculated spent amounts.
  Future<List<BudgetItem>> getCategoryBudgets(int month, int year) async {
    final monthStr = month.toString().padLeft(2, '0');
    final dateFilter = '$year-$monthStr';

    final sql = '''
      SELECT 
        b.${DatabaseConstants.colBudgetId},
        b.${DatabaseConstants.colBudgetCategoryId},
        b.${DatabaseConstants.colBudgetIsOverall},
        b.${DatabaseConstants.colBudgetAmountLimit},
        b.${DatabaseConstants.colBudgetMonth},
        b.${DatabaseConstants.colBudgetYear},
        b.${DatabaseConstants.colBudgetCreatedAt},
        b.${DatabaseConstants.colBudgetUpdatedAt},
        c.${DatabaseConstants.colCategoryName} AS category_name,
        c.${DatabaseConstants.colCategoryIcon} AS category_icon,
        c.${DatabaseConstants.colCategoryColor} AS category_color,
        COALESCE(
          (
            SELECT SUM(t.${DatabaseConstants.colTransactionAmount})
            FROM ${DatabaseConstants.tableTransactions} t
            WHERE t.${DatabaseConstants.colTransactionCategoryId} = b.${DatabaseConstants.colBudgetCategoryId}
              AND t.${DatabaseConstants.colTransactionType} = 'expense'
              AND strftime('%Y-%m', t.${DatabaseConstants.colTransactionDate}) = ?
          ),
          0.0
        ) AS spent_amount
      FROM ${DatabaseConstants.tableBudgets} b
      INNER JOIN ${DatabaseConstants.tableCategories} c
        ON b.${DatabaseConstants.colBudgetCategoryId} = c.${DatabaseConstants.colCategoryId}
      WHERE b.${DatabaseConstants.colBudgetIsOverall} = 0
        AND b.${DatabaseConstants.colBudgetMonth} = ?
        AND b.${DatabaseConstants.colBudgetYear} = ?
      ORDER BY spent_amount DESC, b.${DatabaseConstants.colBudgetAmountLimit} DESC
    ''';

    final results = await _db.rawQuery(sql, [dateFilter, month, year]);
    return results.map(BudgetItem.fromMap).toList();
  }

  /// Sets or updates a category budget.
  Future<BudgetItem> setCategoryBudget({
    required int categoryId,
    required double amountLimit,
    required int month,
    required int year,
  }) async {
    final now = DateTime.now();

    final existing = await _db.query(
      DatabaseConstants.tableBudgets,
      where:
          '${DatabaseConstants.colBudgetCategoryId} = ? AND ${DatabaseConstants.colBudgetMonth} = ? AND ${DatabaseConstants.colBudgetYear} = ?',
      whereArgs: [categoryId, month, year],
      limit: 1,
    );

    if (existing.isEmpty) {
      await _db.insert(
        DatabaseConstants.tableBudgets,
        {
          DatabaseConstants.colBudgetCategoryId: categoryId,
          DatabaseConstants.colBudgetIsOverall: 0,
          DatabaseConstants.colBudgetAmountLimit: amountLimit,
          DatabaseConstants.colBudgetMonth: month,
          DatabaseConstants.colBudgetYear: year,
          DatabaseConstants.colBudgetCreatedAt: now.toIso8601String(),
          DatabaseConstants.colBudgetUpdatedAt: now.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      final id = existing.first[DatabaseConstants.colBudgetId] as int;
      await _db.update(
        DatabaseConstants.tableBudgets,
        {
          DatabaseConstants.colBudgetAmountLimit: amountLimit,
          DatabaseConstants.colBudgetUpdatedAt: now.toIso8601String(),
        },
        where: '${DatabaseConstants.colBudgetId} = ?',
        whereArgs: [id],
      );
    }

    final budgets = await getCategoryBudgets(month, year);
    return budgets.firstWhere((b) => b.categoryId == categoryId);
  }

  /// Deletes a budget by ID.
  Future<int> deleteBudget(int id) async {
    return await _db.delete(
      DatabaseConstants.tableBudgets,
      where: '${DatabaseConstants.colBudgetId} = ?',
      whereArgs: [id],
    );
  }

  /// Returns alert message for categories approaching or exceeding budget.
  Future<String?> getBudgetAlert(int month, int year) async {
    final categoryBudgets = await getCategoryBudgets(month, year);
    for (final budget in categoryBudgets) {
      if (budget.isExceeded) {
        return 'Budget limit exceeded! ${budget.categoryName} category is ${(budget.spentPercentage * 100).toStringAsFixed(0)}% of your budget.';
      }
      if (budget.isNearLimit) {
        return "You're close to your limit! ${budget.categoryName} category is ${(budget.spentPercentage * 100).toStringAsFixed(0)}% of your budget.";
      }
    }
    return null;
  }
}

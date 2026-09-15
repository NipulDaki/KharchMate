import 'package:intl/intl.dart';
import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/database/database_constants.dart';
import 'package:kharch_mate/models/financial_summary.dart';
import 'package:kharch_mate/models/transaction_item.dart';
import 'package:sqflite/sqflite.dart';

class TransactionDao {
  final AppDatabase appDatabase;

  TransactionDao({AppDatabase? appDb}) : appDatabase = appDb ?? AppDatabase();

  Database get _db => appDatabase.db;

  static const String _selectWithJoin = '''
    SELECT 
      t.${DatabaseConstants.colTransactionId},
      t.${DatabaseConstants.colTransactionTitle},
      t.${DatabaseConstants.colTransactionAmount},
      t.${DatabaseConstants.colTransactionType},
      t.${DatabaseConstants.colTransactionCategoryId},
      t.${DatabaseConstants.colTransactionPaymentMethodId},
      t.${DatabaseConstants.colTransactionPaymentMethodName},
      t.${DatabaseConstants.colTransactionDate},
      t.${DatabaseConstants.colTransactionNote},
      t.${DatabaseConstants.colTransactionReceiptPath},
      t.${DatabaseConstants.colTransactionCreatedAt},
      t.${DatabaseConstants.colTransactionUpdatedAt},
      c.${DatabaseConstants.colCategoryName} AS category_name,
      c.${DatabaseConstants.colCategoryIcon} AS category_icon,
      c.${DatabaseConstants.colCategoryColor} AS category_color
    FROM ${DatabaseConstants.tableTransactions} t
    LEFT JOIN ${DatabaseConstants.tableCategories} c
      ON t.${DatabaseConstants.colTransactionCategoryId} = c.${DatabaseConstants.colCategoryId}
  ''';

  /// Inserts a new transaction into SQLite.
  Future<TransactionItem> insertTransaction(TransactionItem transaction) async {
    final now = DateTime.now();
    final itemToSave = transaction.copyWith(
      createdAt: transaction.createdAt,
      updatedAt: now,
    );

    final id = await _db.insert(
      DatabaseConstants.tableTransactions,
      itemToSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return (await getTransactionById(id)) ?? itemToSave.copyWith(id: id);
  }

  /// Updates an existing transaction.
  Future<TransactionItem?> updateTransaction(TransactionItem transaction) async {
    if (transaction.id == null) return null;
    final now = DateTime.now();
    final itemToSave = transaction.copyWith(updatedAt: now);

    final count = await _db.update(
      DatabaseConstants.tableTransactions,
      itemToSave.toMap(),
      where: '${DatabaseConstants.colTransactionId} = ?',
      whereArgs: [transaction.id],
    );

    if (count > 0) {
      return await getTransactionById(transaction.id!);
    }
    return null;
  }

  /// Deletes a transaction by ID.
  Future<int> deleteTransaction(int id) async {
    return await _db.delete(
      DatabaseConstants.tableTransactions,
      where: '${DatabaseConstants.colTransactionId} = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves a transaction with category details by ID.
  Future<TransactionItem?> getTransactionById(int id) async {
    final sql = '''
      $_selectWithJoin
      WHERE t.${DatabaseConstants.colTransactionId} = ?
      LIMIT 1
    ''';
    final results = await _db.rawQuery(sql, [id]);
    if (results.isEmpty) return null;
    return TransactionItem.fromMap(results.first);
  }

  /// Retrieves recent transactions (defaults to 5 for Dashboard).
  Future<List<TransactionItem>> getRecentTransactions({int limit = 5}) async {
    final sql = '''
      $_selectWithJoin
      ORDER BY datetime(t.${DatabaseConstants.colTransactionDate}) DESC, t.${DatabaseConstants.colTransactionId} DESC
      LIMIT ?
    ''';
    final results = await _db.rawQuery(sql, [limit]);
    return results.map(TransactionItem.fromMap).toList();
  }

  /// Retrieves transactions with filters (type, search, date, month, year, category).
  Future<List<TransactionItem>> getTransactions({
    TransactionType? type,
    String? searchQuery,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
    int? categoryId,
    int? limit,
    int? offset,
  }) async {
    final conditions = <String>[];
    final args = <dynamic>[];

    if (type != null) {
      conditions.add('t.${DatabaseConstants.colTransactionType} = ?');
      args.add(type.toDbString());
    }

    if (categoryId != null) {
      conditions.add('t.${DatabaseConstants.colTransactionCategoryId} = ?');
      args.add(categoryId);
    }

    if (date != null) {
      final y = date.year.toString();
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      conditions.add(
        "strftime('%Y-%m-%d', t.${DatabaseConstants.colTransactionDate}) = ?",
      );
      args.add('$y-$m-$d');
    } else if (startDate != null || endDate != null) {
      if (startDate != null) {
        final y = startDate.year.toString();
        final m = startDate.month.toString().padLeft(2, '0');
        final d = startDate.day.toString().padLeft(2, '0');
        conditions.add(
          "strftime('%Y-%m-%d', t.${DatabaseConstants.colTransactionDate}) >= ?",
        );
        args.add('$y-$m-$d');
      }
      if (endDate != null) {
        final y = endDate.year.toString();
        final m = endDate.month.toString().padLeft(2, '0');
        final d = endDate.day.toString().padLeft(2, '0');
        conditions.add(
          "strftime('%Y-%m-%d', t.${DatabaseConstants.colTransactionDate}) <= ?",
        );
        args.add('$y-$m-$d');
      }
    } else if (year != null) {
      if (month != null) {
        final monthStr = month.toString().padLeft(2, '0');
        conditions.add(
          "strftime('%Y-%m', t.${DatabaseConstants.colTransactionDate}) = ?",
        );
        args.add('$year-$monthStr');
      } else {
        conditions.add(
          "strftime('%Y', t.${DatabaseConstants.colTransactionDate}) = ?",
        );
        args.add('$year');
      }
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.trim()}%';
      conditions.add(
        '(t.${DatabaseConstants.colTransactionTitle} LIKE ? OR t.${DatabaseConstants.colTransactionNote} LIKE ? OR c.${DatabaseConstants.colCategoryName} LIKE ?)',
      );
      args.addAll([query, query, query]);
    }

    var sql = _selectWithJoin;
    if (conditions.isNotEmpty) {
      sql += ' WHERE ${conditions.join(' AND ')}';
    }

    sql +=
        ' ORDER BY datetime(t.${DatabaseConstants.colTransactionDate}) DESC, t.${DatabaseConstants.colTransactionId} DESC';

    if (limit != null) {
      sql += ' LIMIT ?';
      args.add(limit);
      if (offset != null) {
        sql += ' OFFSET ?';
        args.add(offset);
      }
    }

    final results = await _db.rawQuery(sql, args);
    return results.map(TransactionItem.fromMap).toList();
  }

  /// Calculates monthly summary for income, expenses, balance, and savings.
  Future<FinancialSummary> getMonthlySummary(int month, int year) async {
    final monthStr = month.toString().padLeft(2, '0');
    final dateFilter = '$year-$monthStr';

    // 1. Total Income & Total Expense
    final summarySql = '''
      SELECT 
        ${DatabaseConstants.colTransactionType} as type,
        COALESCE(SUM(${DatabaseConstants.colTransactionAmount}), 0.0) as total
      FROM ${DatabaseConstants.tableTransactions}
      WHERE strftime('%Y-%m', ${DatabaseConstants.colTransactionDate}) = ?
      GROUP BY ${DatabaseConstants.colTransactionType}
    ''';

    final summaryResults = await _db.rawQuery(summarySql, [dateFilter]);
    double income = 0.0;
    double expense = 0.0;

    for (final row in summaryResults) {
      final type = row['type'] as String?;
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      if (type == 'income') {
        income = total;
      } else if (type == 'expense') {
        expense = total;
      }
    }

    final balance = income - expense;
    final savings = balance > 0 ? balance : 0.0;
    final savingsRate = income > 0 ? ((savings / income) * 100).clamp(0.0, 100.0) : 0.0;

    // 2. Category spending breakdown
    final categoryBreakdown = await getCategorySpending(month, year);

    // 3. Monthly trends (last 6 months up to given month & year)
    final monthlyTrends = await getMonthlyTrends(year, count: 6, endMonth: month);

    return FinancialSummary(
      totalIncome: income,
      totalExpense: expense,
      totalBalance: balance,
      savings: savings,
      savingsRate: savingsRate,
      categoryBreakdown: categoryBreakdown,
      monthlyTrends: monthlyTrends,
    );
  }

  /// Calculates category spending breakdown for a specific month.
  Future<List<CategorySpending>> getCategorySpending(int month, int year) async {
    final monthStr = month.toString().padLeft(2, '0');
    final dateFilter = '$year-$monthStr';

    final sql = '''
      SELECT 
        c.${DatabaseConstants.colCategoryId} AS category_id,
        c.${DatabaseConstants.colCategoryName} AS category_name,
        c.${DatabaseConstants.colCategoryIcon} AS category_icon,
        c.${DatabaseConstants.colCategoryColor} AS category_color,
        COALESCE(SUM(t.${DatabaseConstants.colTransactionAmount}), 0.0) AS total_amount
      FROM ${DatabaseConstants.tableCategories} c
      INNER JOIN ${DatabaseConstants.tableTransactions} t
        ON c.${DatabaseConstants.colCategoryId} = t.${DatabaseConstants.colTransactionCategoryId}
      WHERE t.${DatabaseConstants.colTransactionType} = 'expense'
        AND strftime('%Y-%m', t.${DatabaseConstants.colTransactionDate}) = ?
      GROUP BY c.${DatabaseConstants.colCategoryId}
      ORDER BY total_amount DESC
    ''';

    final results = await _db.rawQuery(sql, [dateFilter]);
    final totalExpense = results.fold<double>(
      0.0,
      (sum, item) => sum + ((item['total_amount'] as num?)?.toDouble() ?? 0.0),
    );

    return results.map((row) {
      final amount = (row['total_amount'] as num?)?.toDouble() ?? 0.0;
      final percentage = totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0;

      return CategorySpending(
        categoryId: row['category_id'] as int? ?? 0,
        categoryName: row['category_name'] as String? ?? '',
        categoryIcon: row['category_icon'] as String? ?? 'category',
        categoryColor: row['category_color'] as String? ?? '#808080',
        amount: amount,
        percentage: percentage,
      );
    }).toList();
  }

  /// Calculates monthly income vs expense trends for charting.
  Future<List<MonthlyTrend>> getMonthlyTrends(
    int year, {
    int count = 6,
    int? endMonth,
  }) async {
    final targetEndMonth = endMonth ?? 12;
    final List<MonthlyTrend> trends = [];

    // Iterate backwards `count` months
    for (int i = count - 1; i >= 0; i--) {
      var m = targetEndMonth - i;
      var y = year;
      while (m <= 0) {
        m += 12;
        y -= 1;
      }

      final monthStr = m.toString().padLeft(2, '0');
      final dateFilter = '$y-$monthStr';

      final sql = '''
        SELECT 
          ${DatabaseConstants.colTransactionType} as type,
          COALESCE(SUM(${DatabaseConstants.colTransactionAmount}), 0.0) as total
        FROM ${DatabaseConstants.tableTransactions}
        WHERE strftime('%Y-%m', ${DatabaseConstants.colTransactionDate}) = ?
        GROUP BY ${DatabaseConstants.colTransactionType}
      ''';

      final rows = await _db.rawQuery(sql, [dateFilter]);
      double inc = 0.0;
      double exp = 0.0;

      for (final r in rows) {
        if (r['type'] == 'income') {
          inc = (r['total'] as num?)?.toDouble() ?? 0.0;
        } else if (r['type'] == 'expense') {
          exp = (r['total'] as num?)?.toDouble() ?? 0.0;
        }
      }

      final date = DateTime(y, m);
      final label = DateFormat('MMM').format(date);

      trends.add(
        MonthlyTrend(
          month: m,
          year: y,
          monthLabel: label,
          income: inc,
          expense: exp,
        ),
      );
    }

    return trends;
  }
}

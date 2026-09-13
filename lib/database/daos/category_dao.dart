import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/database/database_constants.dart';
import 'package:kharch_mate/models/category.dart';
import 'package:sqflite/sqflite.dart';

class CategoryDao {
  final AppDatabase appDatabase;

  CategoryDao({AppDatabase? appDb}) : appDatabase = appDb ?? AppDatabase();

  Database get _db => appDatabase.db;

  /// Retrieves all categories, ordered by name.
  Future<List<CategoryModel>> getAllCategories() async {
    final results = await _db.query(
      DatabaseConstants.tableCategories,
      orderBy: '${DatabaseConstants.colCategoryName} ASC',
    );
    return results.map(CategoryModel.fromMap).toList();
  }

  /// Retrieves categories filtered by type (e.g., expense or income).
  Future<List<CategoryModel>> getCategoriesByType(CategoryType type) async {
    final results = await _db.query(
      DatabaseConstants.tableCategories,
      where:
          '${DatabaseConstants.colCategoryType} = ? OR ${DatabaseConstants.colCategoryType} = ?',
      whereArgs: [type.toDbString(), 'both'],
      orderBy: '${DatabaseConstants.colCategoryName} ASC',
    );
    return results.map(CategoryModel.fromMap).toList();
  }

  /// Retrieves a specific category by ID.
  Future<CategoryModel?> getCategoryById(int id) async {
    final results = await _db.query(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.colCategoryId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return CategoryModel.fromMap(results.first);
  }

  /// Inserts a new custom category.
  Future<CategoryModel> insertCategory(CategoryModel category) async {
    final id = await _db.insert(
      DatabaseConstants.tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return category.copyWith(id: id);
  }

  /// Updates an existing category.
  Future<int> updateCategory(CategoryModel category) async {
    if (category.id == null) return 0;
    return await _db.update(
      DatabaseConstants.tableCategories,
      category.toMap(),
      where: '${DatabaseConstants.colCategoryId} = ?',
      whereArgs: [category.id],
    );
  }

  /// Ensures that the predefined categories exist in the database.
  Future<void> ensurePredefinedCategories() async {
    final predefined = [
      // Predefined Expense Categories
      {'name': 'Rent', 'type': 'expense', 'icon': 'home', 'color': '#26A69A'},
      {'name': 'Food', 'type': 'expense', 'icon': 'fastfood', 'color': '#FF9800'},
      {'name': 'Transport', 'type': 'expense', 'icon': 'directions_car', 'color': '#42A5F5'},
      {'name': 'Shopping', 'type': 'expense', 'icon': 'shopping_bag', 'color': '#7E57C2'},

      // Predefined Income Categories
      {'name': 'Salary', 'type': 'income', 'icon': 'account_balance_wallet', 'color': '#1A6C45'},
      {'name': 'Bonus', 'type': 'income', 'icon': 'stars', 'color': '#E91E63'},
    ];

    final now = DateTime.now().toIso8601String();
    for (final cat in predefined) {
      final existing = await _db.query(
        DatabaseConstants.tableCategories,
        where: '${DatabaseConstants.colCategoryName} = ? AND ${DatabaseConstants.colCategoryType} = ?',
        whereArgs: [cat['name'], cat['type']],
        limit: 1,
      );
      if (existing.isEmpty) {
        await _db.insert(
          DatabaseConstants.tableCategories,
          {
            DatabaseConstants.colCategoryName: cat['name'],
            DatabaseConstants.colCategoryType: cat['type'],
            DatabaseConstants.colCategoryIcon: cat['icon'],
            DatabaseConstants.colCategoryColor: cat['color'],
            DatabaseConstants.colCategoryIsDefault: 1,
            DatabaseConstants.colCategoryCreatedAt: now,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }

  /// Returns the number of transactions associated with a category.
  Future<int> getTransactionCountForCategory(int categoryId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${DatabaseConstants.tableTransactions} WHERE ${DatabaseConstants.colTransactionCategoryId} = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Deletes a category by ID if it has no associated transactions.
  /// Throws [StateError] if transactions are linked to it.
  Future<int> deleteCategory(int id) async {
    final txCount = await getTransactionCountForCategory(id);
    if (txCount > 0) {
      throw StateError(
        'Cannot delete category: $txCount transactions are linked to this category.',
      );
    }
    return await _db.delete(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.colCategoryId} = ?',
      whereArgs: [id],
    );
  }
}

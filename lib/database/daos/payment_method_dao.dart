import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/database/database_constants.dart';
import 'package:kharch_mate/models/payment_method.dart';
import 'package:sqflite/sqflite.dart';

class PaymentMethodDao {
  final AppDatabase appDatabase;

  PaymentMethodDao({AppDatabase? appDb}) : appDatabase = appDb ?? AppDatabase();

  Database get _db => appDatabase.db;

  /// Retrieves all available payment methods.
  Future<List<PaymentMethodModel>> getAll() async {
    final results = await _db.query(
      DatabaseConstants.tablePaymentMethods,
      orderBy: '${DatabaseConstants.colPaymentMethodIsDefault} DESC, ${DatabaseConstants.colPaymentMethodName} ASC',
    );
    return results.map(PaymentMethodModel.fromMap).toList();
  }

  /// Retrieves a payment method by ID.
  Future<PaymentMethodModel?> getById(int id) async {
    final results = await _db.query(
      DatabaseConstants.tablePaymentMethods,
      where: '${DatabaseConstants.colPaymentMethodId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return PaymentMethodModel.fromMap(results.first);
  }

  /// Inserts a new payment method.
  Future<PaymentMethodModel> insert(PaymentMethodModel method) async {
    final id = await _db.insert(
      DatabaseConstants.tablePaymentMethods,
      method.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return PaymentMethodModel(
      id: id,
      name: method.name,
      type: method.type,
      icon: method.icon,
      isDefault: method.isDefault,
      createdAt: method.createdAt,
    );
  }
}

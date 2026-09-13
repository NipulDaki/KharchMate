import 'package:flutter/foundation.dart';
import 'package:kharch_mate/database/database_constants.dart';
import 'package:kharch_mate/database/migrations/database_migration.dart';
import 'package:kharch_mate/database/migrations/migration_v1.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Central database lifecycle manager for KharchMate.
///
/// Features:
/// - Automated versioned migrations with audit tracking
/// - Foreign key enforcement via PRAGMA
/// - Flexible testing support via custom in-memory / file paths
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Database? _db;

  /// Current database schema version. Increment this when adding a new migration!
  static const int currentVersion = 1;

  /// Ordered registry of migrations for continuous schema evolution.
  ///
  /// To add a future migration:
  /// 1. Create `migration_v2.dart` extending [DatabaseMigration].
  /// 2. Append it to this list.
  /// 3. Increment [currentVersion].
  static final List<DatabaseMigration> registeredMigrations = [
    const MigrationV1InitialSchema(),
  ];

  late final MigrationRunner _migrationRunner = MigrationRunner(
    migrations: registeredMigrations,
  );

  /// Getter for the active database instance.
  Database get db {
    if (_db == null || !_db!.isOpen) {
      throw StateError(
        'AppDatabase is not initialized. Call await AppDatabase().init() before accessing.',
      );
    }
    return _db!;
  }

  /// Initialize the database.
  ///
  /// Provide [customPath] when writing tests (e.g., inSqfliteDatabasePath or inMemory).
  Future<Database> init({String? customPath}) async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }

    final String dbPath;
    if (customPath != null) {
      dbPath = customPath;
    } else {
      final databasesDirectory = await getDatabasesPath();
      dbPath = p.join(databasesDirectory, DatabaseConstants.databaseName);
    }

    debugPrint('Initializing SQLite database at: $dbPath');

    _db = await openDatabase(
      dbPath,
      version: currentVersion,
      onConfigure: (db) async {
        // Enforce SQLite Foreign Key constraints
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        debugPrint('AppDatabase: Running onCreate for version $version');
        await _migrationRunner.runMigrations(db, 0, version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        debugPrint(
          'AppDatabase: Running onUpgrade from $oldVersion to $newVersion',
        );
        await _migrationRunner.runMigrations(db, oldVersion, newVersion);
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        debugPrint(
          'AppDatabase: Running onDowngrade from $oldVersion to $newVersion',
        );
        await _migrationRunner.rollbackMigrations(db, oldVersion, newVersion);
      },
    );

    return _db!;
  }

  /// Closes the database connection.
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  /// Wipes all data by dropping and re-running all migrations.
  /// Useful for testing, user logout, or 'Clear Data' feature.
  Future<void> resetDatabase() async {
    if (_db != null && _db!.isOpen) {
      await _migrationRunner.rollbackMigrations(_db!, currentVersion, 0);
      await _migrationRunner.runMigrations(_db!, 0, currentVersion);
    }
  }
}

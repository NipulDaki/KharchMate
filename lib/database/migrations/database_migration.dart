import 'package:flutter/foundation.dart';
import 'package:kharch_mate/database/database_constants.dart';
import 'package:sqflite/sqflite.dart';

/// Abstract contract that every database migration must implement.
abstract class DatabaseMigration {
  const DatabaseMigration();

  /// Target schema version this migration transitions to.
  int get version;

  /// Human-readable summary of this migration step.
  String get description;

  /// Apply changes for this version.
  Future<void> up(DatabaseExecutor db);

  /// Roll back changes for this version (optional / best-effort).
  Future<void> down(DatabaseExecutor db);
}

/// Executes migrations sequentially and records audit logs in [DatabaseConstants.tableMigrations].
class MigrationRunner {
  final List<DatabaseMigration> migrations;

  MigrationRunner({required this.migrations}) {
    // Sort migrations ascending by version
    migrations.sort((a, b) => a.version.compareTo(b.version));
  }

  /// Ensures schema_migrations tracking table exists.
  Future<void> _ensureMigrationTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableMigrations} (
        ${DatabaseConstants.colMigrationVersion} INTEGER PRIMARY KEY,
        ${DatabaseConstants.colMigrationDescription} TEXT NOT NULL,
        ${DatabaseConstants.colMigrationAppliedAt} TEXT NOT NULL
      );
    ''');
  }

  /// Run all migrations required from [oldVersion] up to [newVersion].
  Future<void> runMigrations(Database db, int oldVersion, int newVersion) async {
    debugPrint(
      'Database Migration: Upgrading from v$oldVersion to v$newVersion...',
    );
    await _ensureMigrationTable(db);

    for (final migration in migrations) {
      if (migration.version > oldVersion && migration.version <= newVersion) {
        debugPrint(
          'Applying Migration v${migration.version}: ${migration.description}',
        );
        await db.transaction((txn) async {
          await migration.up(txn);
          await txn.insert(
            DatabaseConstants.tableMigrations,
            {
              DatabaseConstants.colMigrationVersion: migration.version,
              DatabaseConstants.colMigrationDescription: migration.description,
              DatabaseConstants.colMigrationAppliedAt:
                  DateTime.now().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        });
        debugPrint('Migration v${migration.version} applied successfully.');
      }
    }
  }

  /// Roll back migrations from [currentVersion] down to [targetVersion].
  Future<void> rollbackMigrations(
    Database db,
    int currentVersion,
    int targetVersion,
  ) async {
    debugPrint(
      'Database Rollback: Downgrading from v$currentVersion to v$targetVersion...',
    );
    await _ensureMigrationTable(db);

    final reversed = migrations.reversed.toList();
    for (final migration in reversed) {
      if (migration.version <= currentVersion &&
          migration.version > targetVersion) {
        debugPrint(
          'Rolling back Migration v${migration.version}: ${migration.description}',
        );
        await db.transaction((txn) async {
          await migration.down(txn);
          await txn.delete(
            DatabaseConstants.tableMigrations,
            where: '${DatabaseConstants.colMigrationVersion} = ?',
            whereArgs: [migration.version],
          );
        });
        debugPrint('Migration v${migration.version} rolled back.');
      }
    }
  }

  /// Returns all applied migration records from the database.
  Future<List<Map<String, dynamic>>> getAppliedMigrations(Database db) async {
    await _ensureMigrationTable(db);
    return await db.query(
      DatabaseConstants.tableMigrations,
      orderBy: '${DatabaseConstants.colMigrationVersion} ASC',
    );
  }
}

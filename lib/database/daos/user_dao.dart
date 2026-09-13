import 'package:kharch_mate/database/app_database.dart';
import 'package:kharch_mate/database/database_constants.dart';
import 'package:kharch_mate/models/user_profile.dart';
import 'package:sqflite/sqflite.dart';

class UserDao {
  final AppDatabase appDatabase;

  UserDao({AppDatabase? appDb}) : appDatabase = appDb ?? AppDatabase();

  Database get _db => appDatabase.db;

  /// Retrieves the active user profile, or null if no user is registered yet.
  Future<UserProfile?> getUserProfile() async {
    final results = await _db.query(
      DatabaseConstants.tableUsers,
      limit: 1,
      orderBy: '${DatabaseConstants.colUserId} ASC',
    );
    if (results.isEmpty) return null;
    return UserProfile.fromMap(results.first);
  }

  /// Checks whether a user has completed the initial onboarding/name entry.
  Future<bool> hasUser() async {
    final user = await getUserProfile();
    return user != null && user.name.trim().isNotEmpty;
  }

  /// Inserts a new user profile or updates the existing one.
  Future<UserProfile> saveUserProfile(UserProfile profile) async {
    final existing = await getUserProfile();
    final now = DateTime.now();

    if (existing == null) {
      final map = profile
          .copyWith(
            createdAt: profile.createdAt,
            updatedAt: now,
          )
          .toMap();

      final insertedId = await _db.insert(
        DatabaseConstants.tableUsers,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return profile.copyWith(id: insertedId, updatedAt: now);
    } else {
      final updated = profile.copyWith(
        id: existing.id,
        createdAt: existing.createdAt,
        updatedAt: now,
      );

      await _db.update(
        DatabaseConstants.tableUsers,
        updated.toMap(),
        where: '${DatabaseConstants.colUserId} = ?',
        whereArgs: [existing.id],
      );
      return updated;
    }
  }

  /// Convenience method to save or update the user's name and optional email during onboarding.
  Future<UserProfile> saveUserName(String name, {String? email}) async {
    final existing = await getUserProfile();
    final now = DateTime.now();
    final cleanEmail =
        (email != null && email.trim().isNotEmpty) ? email.trim() : null;

    if (existing == null) {
      return await saveUserProfile(
        UserProfile(
          name: name.trim(),
          email: cleanEmail,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      final updated = existing.copyWith(
        name: name.trim(),
        email: cleanEmail ?? existing.email,
        updatedAt: now,
      );
      await _db.update(
        DatabaseConstants.tableUsers,
        updated.toMap(),
        where: '${DatabaseConstants.colUserId} = ?',
        whereArgs: [existing.id],
      );
      return updated;
    }
  }

  /// Updates dark mode setting.
  Future<void> updateDarkMode(bool isDarkMode) async {
    final existing = await getUserProfile();
    if (existing != null) {
      await _db.update(
        DatabaseConstants.tableUsers,
        {
          DatabaseConstants.colUserIsDarkMode: isDarkMode ? 1 : 0,
          DatabaseConstants.colUserUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DatabaseConstants.colUserId} = ?',
        whereArgs: [existing.id],
      );
    }
  }

  /// Deletes the user profile (e.g. upon logout/reset).
  Future<void> deleteUser() async {
    await _db.delete(DatabaseConstants.tableUsers);
  }
}

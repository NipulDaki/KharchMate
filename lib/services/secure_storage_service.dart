import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  late FlutterSecureStorage _storage;

  SecureStorageService() {
    _storage = const FlutterSecureStorage();
  }

  Future writeSecureData(String key, dynamic value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<String?> getString(String key) async {
    if (await _storage.containsKey(key: key)) {
      return await _storage.read(key: key);
    }
    return null;
  }

  Future<int?> getInt(String key) async {
    if (await _storage.containsKey(key: key)) {
      var value = await _storage.read(key: key);
      if (value is int) {
        return int.parse(value!);
      }
    }
    return null;
  }

  Future<bool?> getBool(String key) async {
    if (await _storage.containsKey(key: key)) {
      var value = await _storage.read(key: key);
      if (value is bool) {
        return bool.parse(value!);
      }
    }
    return null;
  }

  Future<double?> getDouble(String key) async {
    if (await _storage.containsKey(key: key)) {
      var value = await _storage.read(key: key);
      if (value is double) {
        return double.parse(value!);
      }
    }
    return null;
  }

  Future<void> clearStorage() async {
    await _storage.deleteAll();
  }
}

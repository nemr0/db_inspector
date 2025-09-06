import 'db_type.dart';

/// An abstract class for a generic key-value database.
abstract class KeyValueDB extends DB {
  /// Sets [value] for the specified [key].
  Future<void> setValue(String key, dynamic value);
  /// Retrieves the value associated with the specified [key].
  Future<dynamic> getValue(String key);
  /// Deletes the entry associated with the specified [key].
  Future<void> deleteKey(String key);
  /// Retrieves all keys along with their corresponding values.
  Future<Map<String, dynamic>> getAllKeysAndValues();
}
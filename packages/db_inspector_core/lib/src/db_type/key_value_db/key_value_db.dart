import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';


/// An abstract class for a generic key-value database.
abstract class KeyValueDB extends DB {
  
  /// Sets [value] for the specified [key].
  Future<void> setValue(String key, dynamic value);
  /// Retrieves the value associated with the specified [key].
  Future<Object?> getValue(String key);
  /// Deletes the entry associated with the specified [key].
  Future<void> deleteKey(String key);
  /// Retrieves all keys along with their corresponding values.
  Future<Map<String, dynamic>> getAllKeysAndValues();

  /// Watches for changes in the key-value pairs and emits a stream of key-value tuples.
  Stream<StreamEvent> watcher();

}

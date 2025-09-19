import '../../../db_inspector_core.dart';

/// Abstraction for a "box" based database (for example Hive-like stores).
///
/// Implementations should provide basic CRUD operations for named boxes,
/// as well as streams to observe changes. This interface keeps the DB
/// operations simple and storage-agnostic so the rest of the inspector
/// code can work with any box-backed implementation.
///
/// Example:
/// ```dart
/// final db = MyBoxDBImplementation();
/// await db.insertToBox('settings', 'theme', 'dark');
/// final settings = await db.getBoxData('settings');
/// db.watchBox(boxName: 'settings').listen((changes) {
///   // react to changes in the settings box
/// });
/// ```
abstract class BoxDB implements DB {

  /// Delete the entry with [key] from the specified [boxName].
  ///
  /// Returns a Future that completes when the deletion is finished.
  Future<void> deleteFromBox(String boxName, dynamic key);

  /// Clear all entries from the specified box and return the number of items removed.
  ///
  /// Implementations may return the count of removed items or 0 if not supported.
  Future<int> clearBox(String boxName);


  /// Retrieve all data from the specified box as a list of `T`.
  ///
  /// - [boxName]: name of the box to query.
  /// - `T` is the expected type of stored values; implementations should cast or map
  ///   stored values to `T` where possible.
  ///
  /// Returns a Future resolving to the list of values in the box.
  Future<List<T>> getBoxData<T>(String boxName);

  /// Watch changes in a specific box. Emits a map where the key is the changed entry's
  /// key and the value is the corresponding [StreamEvent] describing the change.
  ///
  /// - [boxName]: box to observe.
  /// - [addInitialData]: when true, the stream should emit the current contents
  ///   (or an initial snapshot) before streaming further updates.
  ///
  /// The generic `T` represents the expected value type for consumers that will
  /// interpret the contained events.
  Stream<Map<dynamic, StreamEvent>> watchBox<T>({
    required String boxName,
    bool addInitialData = true,
  });

  /// Watch the length (number of entries) of all boxes (or the relevant box set).
  ///
  /// Emits a map of boxName -> currentLength. When [addInitialData] is true the stream
  /// should emit an initial snapshot of lengths before subsequent updates.
  Stream<Map<String,int>> watchBoxLength({bool addInitialData = true,});
}

import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:hive/hive.dart';

class HiveDB implements BoxDB {
  final Set<Box> boxes;
  final HiveStorageBackendPreference storageBackendPreference;
  bool _isConnected = false;
  HiveDB({
    required this.boxes,
    this.storageBackendPreference = HiveStorageBackendPreference.native,
  });



  @override
  Future<void> connect() async {
    if (_isConnected) return;
    final closedBoxes = boxes.where((e) => !e.isOpen).toList();
    for (final box in closedBoxes) {
      await Hive.openBox(box.name);
    }
    _isConnected = true;
  }

  @override
  Future<void> disconnect() {
    return Hive.close();
  }

  @override
  List<String> getOpenBoxes() {
    return boxes.where((e) => e.isOpen).map((e) => e.name).toList();
  }

  @override
  String get name => 'Hive';

  @override
  Future<void> insertToBox(String box, key, value) {
    return Hive.box(box).put(key, value);
  }

  @override
  Future<int> clearBox(String box) {
   return Hive.box(box).clear();
  }

  @override
  Future<void> deleteFromBox(String box, key) {
    return Hive.box(box).delete(key);
  }



/// Make a merged stream of all box watch streams with start value of current box data
  /// Make a merged stream of all box watch streams with start value of current box data
  @override
  Stream<StreamEvent<String, dynamic>> watchBoxes() {
    return startMergedStream<String, dynamic>(
      boxes.map((box) {
        return (() async* {
          for (final key in box.keys) {
            yield BoxEventData(
              key: key.toString(),
              deleted: false,
              data: box.get(key),
              streamId: box.name,
            );
          }
          yield* box.watch().map(
                (data) => BoxEventData(
              key: data.key.toString(),
              deleted: data.deleted,
              data: data.value,
              streamId: box.name,
            ),
          );
        })();
      }),
    );
  }




  @override
  bool get isConnected => _isConnected;

  @override
  Future<List<T>> getBoxData<T>(String boxName) {
    final box = Hive.box<T>(boxName);
    return Future.value(box.values.toList());
  }
}

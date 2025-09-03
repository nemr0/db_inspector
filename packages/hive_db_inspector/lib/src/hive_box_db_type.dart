import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_db_inspector/src/hive_box_details.dart';

class HiveBoxDBType implements BoxDB {
  final Set<HiveBoxDetails> boxes;
  final String path;
  final HiveStorageBackendPreference storageBackendPreference;
  bool _isConnected = false;
  HiveBoxDBType({
    required this.boxes,
    required this.path,
    this.storageBackendPreference = HiveStorageBackendPreference.native,
  });

  final Set<LazyBox> _openBoxes = {};

  @override
  Future<void> connect() async {
    Hive.init(path, backendPreference: storageBackendPreference);
    final closedBoxes = boxes.where((box) => Hive.isBoxOpen(box.name) == false);
    for (final box in closedBoxes) {

        await Hive.openLazyBox(
          box.name,
          compactionStrategy: box.compactionStrategy,
          encryptionCipher: box.cipher,
          keyComparator: box.keyComparator,
          crashRecovery: box.crashRecovery,
          path: box.path,
          collection: box.collection,

      );
    }
    _isConnected = true;
  }

  @override
  Future<void> disconnect() {
    return Hive.close();
  }

  @override
  List<String> getOpenBoxes() {
    return _openBoxes.where((e) => e.isOpen).map((e) => e.name).toList();
  }

  @override
  String get name => 'HiveBoxDBType';

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

  @override
  Future<void> openBox(String boxName) async {
    _openBoxes.add(await Hive.openLazyBox(boxName));
  }


  @override
  Stream<StreamEvent<dynamic, dynamic>> watchBoxes() {
    return startMergedStream<String, dynamic>(
      _openBoxes.map(
        (box) => box.watch().map(
          (data) => BoxEventData(
            key: data.key,
            deleted: data.deleted, data: data.value, streamId:box.name,
          ),
        ),
      ),
    );
  }




  @override
  bool get isConnected => _isConnected;
}

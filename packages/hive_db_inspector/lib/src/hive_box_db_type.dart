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
    return _getBoxByName(box).put(key, value);
  }

  @override
  Future<int> clearBox(String box) {
    return _getBoxByName(box).clear();
  }

  @override
  Future<void> deleteFromBox(String box, key) {
    return _getBoxByName(box).delete(key);
  }
  Box _getBoxByName(String boxName) {
    return boxes.firstWhere((e) => e.name == boxName);
  }

  @override
  bool get isConnected => _isConnected;

  @override
  Future<List<T>> getBoxData<T>(String boxName) {
    final box = Hive.box<T>(boxName);
    return Future.value(box.values.toList());
  }

  @override
  Stream<int> get onChange {
    var count = 0;
    return Stream.multi((ctr) async {
       for(final box in boxes) {
        await ctr.addStream(box.watch().map((e){
          return ++count;
        }));
      }
    });
  }

  @override
  Stream<Map<dynamic,StreamEvent>> watchBox<T>({
    required String boxName,
    bool addInitialData = true,
  }) async*{

    final box = _getBoxByName(boxName);
    final Map<dynamic, StreamEvent> data = {};
    if (addInitialData) {
      for (final key in box.keys) {
        data[key] = StreamEvent(
          key: key,
          isDeleted: false,
          data: box.get(key),
          streamId: box.name,
        );
      }
      yield Map<dynamic, StreamEvent>.from(data);
    }
    yield* box.watch().map((value){
        final old = data[value.key];
      if(value.deleted && old != null) {
        data[value.key] = old.copyWith(isDeleted: true);
      } else{
        data[value.key] = StreamEvent(
          key: value.key,
          isDeleted: value.deleted,
          data: value.value,
          streamId: box.name,
        );
      }




      return Map<dynamic, StreamEvent>.from(data);
    });
  }

  @override
  Stream<Map<String, int>> watchBoxLength({bool addInitialData = true}) {
    return Stream.multi((controller) {
      final currentBoxes = boxes;
      final Map<String, int> boxesToLength = {};

      // Initialize box lengths if requested
      if (addInitialData) {
        for (final box in currentBoxes) {
          boxesToLength[box.name] = box.length;
        }
        controller.add(Map.from(boxesToLength));
      }

      // Listen to changes in each box
      for (final box in currentBoxes) {
        controller.addStream(
          box.watch().map((data) {
            if (data.deleted) {
              boxesToLength[box.name] = (boxesToLength[box.name] ?? 0) - 1;
            } else {
              boxesToLength[box.name] = (boxesToLength[box.name] ?? 0) + 1;
            }
           return Map.from(boxesToLength);
          }),
        );
      }


    });
  }
}

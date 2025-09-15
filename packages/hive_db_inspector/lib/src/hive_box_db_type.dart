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
  /// Make a merged stream of all box watch streams with start value of current box data
  /// Make a merged stream of all box watch streams with start value of current box data
  @override
  Stream<StreamEvent<String, dynamic,dynamic>> watchBoxes({
    bool addInitialData = true,
  }) {
    return startMergedStream<String, dynamic,dynamic>(
      boxes.map((box) {
        return (() async* {
          if (addInitialData) {
            for (final key in box.keys) {
              yield StreamEvent(
                key: key,
                isDeleted: false,
                data: box.get(key),
                streamId: box.name,
              );
            }
          }
          yield* box.watch().map(
            (data) => StreamEvent(
              key: data.key,
              isDeleted: data.deleted,
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

  @override
  Stream<int> get onChange {
    var count = 0;
    return watchBoxes(addInitialData: false).map((_) {
      count = ++count;
      return count;
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
      print('data is empty, adding initial data for box: $boxName');
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
      print(addInitialData);
      print(data);
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
      final List<StreamSubscription> listeners = [];

      // Initialize box lengths if requested
      if (addInitialData) {
        for (final box in currentBoxes) {
          boxesToLength[box.name] = box.length;
        }
        controller.add(Map.from(boxesToLength));
      }

      // Listen to changes in each box
      for (final box in currentBoxes) {
        listeners.add(
          box.watch().listen((data) {
            if (data.deleted) {
              boxesToLength[box.name] = (boxesToLength[box.name] ?? 0) - 1;
            } else {
              boxesToLength[box.name] = (boxesToLength[box.name] ?? 0) + 1;
            }
            controller.add(Map.from(boxesToLength));
          }),
        );
      }

      // Clean up listeners when stream is cancelled
      controller.onCancel = () {
        for (final listener in listeners) {
          listener.cancel();
        }
      };

      controller.onPause = () {
        for (final listener in listeners) {
          listener.pause();
        }
      };
      controller.onResume = () {
        for (final listener in listeners) {
          listener.resume();
        }
      };
    });
  }
}

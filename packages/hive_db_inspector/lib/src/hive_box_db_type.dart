import 'dart:async';
import 'dart:typed_data' show Uint8List;

import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:hive/src/box/default_compaction_strategy.dart';
import 'package:hive/src/box/default_key_comparator.dart';

class HiveDB implements BoxDB {
  final Map<String, BoxOptions> boxNamesWithOptions;
  final Set<Box> boxes;
  final Set<Box> _boxes = {};

  /// Creates a HiveDB instance that manages the provided set of Hive [boxes]
  /// or the provided [boxNamesWithOptions].
  ///
  /// - [boxes]: The set of boxes the instance will manage. Boxes may already
  ///   be open or closed. This constructor does not open closed boxes; it
  ///   only stores the provided set. Call `connect()` to filter out any
  ///   boxes that are not open (the current `connect()` implementation
  ///   removes closed boxes from the internal set).
  ///
  /// - [boxNamesWithOptions]: A map of box names to options used to open
  ///   boxes when `connect()` is called. Boxes listed here will be opened
  ///   if not already open.
  ///
  /// One of [boxes] or [boxNamesWithOptions] must be non-empty. An assertion
  /// is raised if both are empty to prevent creating an instance that manages
  /// no boxes.
  HiveDB({
    this.boxes = const {},
    this.boxNamesWithOptions = const {},
  }) : assert(
         boxes.isNotEmpty || boxNamesWithOptions.isNotEmpty,
         'Either boxes or boxNamesWithOptions must be provided',
       );

  @override
  Future<void> connect() async {
    for (final entry in boxNamesWithOptions.entries) {
      final name = entry.key;
      final boxOptions = entry.value;
      if (!Hive.isBoxOpen(name)) {
        final box = await Hive.openBox(
          name,
          encryptionCipher: boxOptions.encryptionCipher,
          keyComparator: boxOptions.keyComparator,
          compactionStrategy: boxOptions.compactionStrategy,
          crashRecovery: boxOptions.crashRecovery,
          bytes: boxOptions.bytes,
          collection: boxOptions.collection,
          path: boxOptions.path,
        );
        _boxes.add(box);
      } else {
        _boxes.add(Hive.box(name));
      }
    }
    for (final box in boxes) {
      if (Hive.isBoxOpen(box.name)) {
        _boxes.add(box);
      }
    }
  }

  @override
  Future<void> disconnect() {
    return Hive.close();
  }

  @override
  String get name => 'Hive';

  @override
  Future<int> clearBox(String box) {
    return _getBoxByName(box).clear();
  }

  @override
  Future<void> deleteFromBox(String box, key) {
    return _getBoxByName(box).delete(key);
  }

  Box _getBoxByName(String boxName) {
    // Returns the first matching box by name from the provided `boxes` set.
    // If no box with the given name exists, `firstWhere` will throw a
    // StateError. Callers should ensure the box exists (e.g., via
    // getOpenBoxes() or by managing the provided `boxes` set).
    return _boxes.firstWhere((e) => e.name == boxName);
  }

  @override
  Future<List<T>> getBoxData<T>(String boxName) {
    final box = Hive.box<T>(boxName);
    return Future.value(box.values.toList());
  }

  @override
  Stream<int> get onChange {
    var count = 0;
    return Stream.multi((ctr) async {
      for (final box in _boxes) {
        await ctr.addStream(
          box.watch().map((e) {
            return ++count;
          }),
        );
      }
    });
  }

  @override
  Stream<Map<dynamic, StreamEvent>> watchBox<T>({
    required String boxName,
    bool addInitialData = true,
  }) async* {
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
    yield* box.watch().map((value) {
      final old = data[value.key];
      if (value.deleted && old != null) {
        data[value.key] = old.copyWith(isDeleted: true);
      } else {
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
      final currentBoxes = _boxes;
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

class BoxOptions extends Equatable {
  final HiveCipher? encryptionCipher;
  final KeyComparator keyComparator;
  final CompactionStrategy compactionStrategy;
  final bool crashRecovery = true;
  final String? path;
  final Uint8List? bytes;
  final String? collection;

  const BoxOptions({
    this.encryptionCipher,
    this.path,
    this.bytes,
    this.collection,
    this.compactionStrategy = defaultCompactionStrategy,
    this.keyComparator = defaultKeyComparator,
  });

  @override
  List<Object?> get props => [
    encryptionCipher,
    keyComparator,
    compactionStrategy,
    crashRecovery,
    path,
    bytes,
    collection,
  ];
}

// ignore_for_file: implementation_imports
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:hive/src/box/default_compaction_strategy.dart';
import 'package:hive/src/box/default_key_comparator.dart';
import 'package:equatable/equatable.dart';
class HiveBoxDetails extends Equatable {
  final String name;
  final HiveCipher? cipher;
  final KeyComparator keyComparator;
  final CompactionStrategy compactionStrategy;
  final bool crashRecovery;
  final String? path;
  final Uint8List? bytes;
  final String? collection;

  const HiveBoxDetails({
    required this.name,
    this.cipher,
    this.keyComparator = defaultKeyComparator,
    this.compactionStrategy = defaultCompactionStrategy,
    this.crashRecovery = true,
    this.path,
    this.bytes,
    this.collection,
  });

  @override
  List<Object?> get props => [name, cipher, keyComparator, compactionStrategy, crashRecovery, path, bytes, collection];


}
import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/foundation.dart';

import 'db_type.dart';

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

   KeyValueController get controller;
}

 class KeyValueController extends ValueNotifier<Map<String,dynamic>>{
  KeyValueController( this.watcher, this.getInitialData) : super({}){
    _subscription = watcher.listen(_listener);
  }
  final Stream<StreamEvent> watcher;
  final Future<Map<String,dynamic>> Function() getInitialData;
  StreamSubscription<StreamEvent>? _subscription;

  void _listener(StreamEvent event) {
    if(event.isDeleted){
      value.remove(event.key);
    } else {
      value[event.key] = event.data;
    }
    notifyListeners();
  }
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
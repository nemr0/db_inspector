
import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/foundation.dart';


class KeyValueController extends ValueNotifier<Map<String,StreamEvent>>{
  KeyValueController(this.keyValueDB) : super({}){
    refresh();
    _subscription = keyValueDB.watcher().listen(_listener);
  }
  final KeyValueDB keyValueDB;

  Future<void> refresh() async {
    value = (await keyValueDB.getAllKeysAndValues()).map((e,v){
      return MapEntry(e, StreamEvent(key: e, data: v, isDeleted: false,streamId: null,));
    });
    notifyListeners();
  }
  StreamSubscription<StreamEvent>? _subscription;

  void _listener(StreamEvent event) {
    if(event.isDeleted){
      value.remove(event.key);
    } else {
      value[event.key] = event;
    }
    notifyListeners();
  }
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
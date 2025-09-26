
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../db_inspector_core.dart';

class KeyValueController extends ValueNotifier<Map<String,StreamEvent>>{
  KeyValueController(this.db) : super({}){
    refresh();
    _subscription = db.watcher().listen(_listener);
  }
  final KeyValueDB db;

  Future<void> refresh() async {
    value = (await db.getAllKeysAndValues()).map((e,v){
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
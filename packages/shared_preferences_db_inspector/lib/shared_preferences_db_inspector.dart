import 'dart:async';
import 'dart:convert';

import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesDbInspector implements KeyValueDB {
  late final SharedPreferences _preferences;
  final Map<String, Object?> _cache = {};
  @override
  Future<void> connect() async{
    _preferences = await SharedPreferences.getInstance();
  }

  @override
  Future<void> deleteKey(String key) {
   return _preferences.remove(key);
  }

  @override
  Future<void> disconnect() async {
    _cache.clear();

  }

  @override
  Future<Map<String, dynamic>> getAllKeysAndValues() {
    final keys = _preferences.getKeys();
    final map = <String, dynamic>{};
    for (final key in keys) {
      map[key] = _preferences.get(key);
    }
    print('getAllKeysAndValues: $map');
    return Future.value(map);
  }
  @override
  Future<Object?> getValue(String key) async {
    return _preferences.get(key);
  }

  @override
  String get name => 'Shared Preferences';

  @override
  Stream<int> get noOfProperties {
    return Stream<int>.multi((controller){
      int count = _preferences.getKeys().length;
      print('count: $count');
      controller.add(count);
      Timer timer = Timer.periodic(const Duration(seconds: 3),(t){
        print('streaming');
        final currentLength = _preferences.getKeys().length;
        if(currentLength == count){
          return;
        }
        count = currentLength;
        controller.add(currentLength);
      });
      controller.onCancel = (){
        timer.cancel();
      };
      controller.onPause = (){
        timer.cancel();
      };
      controller.onResume = (){
        // Restart the timer
       timer = Timer.periodic(const Duration(seconds: 5),(t)=>_preferences.getKeys().length);
      };
    });
  }

  @override
  Future<void> setValue(String key,dynamic value) {
    final asInt =int.tryParse(value.toString());
    if(asInt is int){
      return _preferences.setInt(key, asInt);
    }
    final asDouble = double.tryParse(value.toString());
    if(asDouble is double){
      return _preferences.setDouble(key, asDouble);
    }
    final asBool = bool.tryParse(value.toString());
    if(asBool is bool){
      return _preferences.setBool(key, asBool);
    }
    final listString = _checkIfListString(value);
    if(listString != null){
      return _preferences.setStringList(key, listString);
    } else if(value is String){
      return _preferences.setString(key, value);
    } else if (value == null) {
      return _preferences.setString(key, 'null');
    }else {
      throw UnimplementedError('Type ${value.runtimeType} is not supported');
    }
  }
  List<String>? _checkIfListString(dynamic value){
    try{
      final decoded = jsonDecode(value);
      if(decoded is List<String>){
        return decoded;
      }
      return null;
    } catch(e){
      return null;
    }
  }

  @override
  Stream<StreamEvent> watcher() {
    return Stream<StreamEvent>.multi((controller){
      Timer timer = Timer.periodic(const Duration(seconds: 5),(t)=>_periodicallyAddStreamEvents(t, controller) );
      controller.onCancel = (){
        timer.cancel();
      };
      controller.onPause = (){
        timer.cancel();
      };
      controller.onResume = (){
        // Restart the timer
       timer = Timer.periodic(const Duration(seconds: 5),(t)=>_periodicallyAddStreamEvents(t, controller) );
      };
    });
  }
 void _periodicallyAddStreamEvents(Timer timer,StreamController<StreamEvent> controller) async {
    print('Checking for changes in SharedPreferences...');
    final currentKeys = _preferences.getKeys();
    // Check for added or updated keys
    for (final key in currentKeys) {
      final currentValue = _preferences.get(key);
      if (!_cache.containsKey(key)) {
        // New key added
        _cache[key] = currentValue;
        controller.add(StreamEvent(streamId: null, data: currentValue, key: key, isDeleted: false));
      } else if (_cache[key] != currentValue) {
        // Key value updated
        _cache[key] = currentValue;
        controller.add(StreamEvent(streamId: null, data: currentValue, key: key, isDeleted: false));
      }
    }
    // Check for deleted keys
    final cachedKeys = List<String>.from(_cache.keys);
    for (final key in cachedKeys) {
      if (!currentKeys.contains(key)) {
        // Key deleted
        final oldValue = _cache.remove(key);
        controller.add(StreamEvent(streamId: null, data: oldValue, key: key, isDeleted: true));
      }
    }
  }

}


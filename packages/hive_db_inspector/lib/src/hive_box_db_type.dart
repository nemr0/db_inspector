import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_db_inspector/src/hive_box_details.dart';
class HiveBoxDBType implements BoxDB{
  final List<HiveBoxDetails> boxes;
  final String path;
  final HiveStorageBackendPreference storageBackendPreference;
  HiveBoxDBType({required this.boxes, required this.path,this.storageBackendPreference = HiveStorageBackendPreference.native});
  @override
  Future<void> closeBox(String boxName) {

    // TODO: implement closeBox
    throw UnimplementedError();
  }

  @override
  Future<void> connect() async {
    Hive.init(path, backendPreference: storageBackendPreference);
    final closedBoxes = boxes.where((box) => Hive.isBoxOpen(box.name)).toList();
    for(final box in closedBoxes){
      await Hive.openBox(box.name);
    }

  }

  @override
  Future<void> disconnect() {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  List<String> getOpenBoxes() {
    // TODO: implement getOpenBoxes
    throw UnimplementedError();
  }

  @override
  bool isConnected() {
    // TODO: implement isConnected
    throw UnimplementedError();
  }

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  Future<void> openBox(String boxName) {
    // TODO: implement openBox
    throw UnimplementedError();
  }

  @override
  Future<void> putInBox(String boxName, key, value) {
    // TODO: implement putInBox
    throw UnimplementedError();
  }

  @override
  // TODO: implement version
  String get version => throw UnimplementedError();

  @override
  List<Object?> get props => [boxes, path];

  @override
  bool? get stringify => true;


}
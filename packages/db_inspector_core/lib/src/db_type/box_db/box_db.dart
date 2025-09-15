import '../../helpers/tagged_merge/merged_stream.dart';
import '../db_type.dart';
abstract class BoxDB implements DB {

  Future<void> insertToBox(String boxName, dynamic key, dynamic value);
  Future<void> deleteFromBox(String boxName, dynamic key);
  Future<int> clearBox(String boxName);
  List<String> getOpenBoxes();
  Future<List<T>> getBoxData<T>(String boxName);
  Stream<StreamEvent<dynamic, dynamic,dynamic>> watchBoxes({bool addInitialData = true});
  Stream<Map<dynamic, StreamEvent>> watchBox<T>({required String boxName, bool addInitialData = true, });
  Stream<Map<String,int>> watchBoxLength({bool addInitialData = true,});
}

typedef BoxData = (String boxName, Map<dynamic, dynamic> boxData);
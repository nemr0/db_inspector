import '../../helpers/tagged_merge/merged_stream.dart';
import '../db_type.dart';
abstract class BoxDB implements DBType {

  Future<void> insertToBox(String boxName, dynamic key, dynamic value);
  Future<void> deleteFromBox(String boxName, dynamic key);
  Future<int> clearBox(String boxName);
  List<String> getOpenBoxes();

  Stream<StreamEvent<dynamic, dynamic>> watchBoxes();
  Future<void> openBox(String boxName);

}

typedef BoxData = (String boxName, Map<dynamic, dynamic> boxData);
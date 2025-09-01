import '../db_type.dart';
import 'package:equatable/equatable.dart';
/// An abstract class for a box-based key-value database.
abstract class BoxDB extends Equatable implements DBType {

  /// Opens the box identified by [boxName].
  Future<void> openBox(String boxName);
  /// Closes the box identified by [boxName].
  Future<void> closeBox(String boxName);
  /// Retrieves a list of names of the currently open boxes.
  List<String> getOpenBoxes();
  /// Inserts a key-value pair into the box identified by [boxName].
  Future<void> putInBox(String boxName, dynamic key, dynamic value);

}
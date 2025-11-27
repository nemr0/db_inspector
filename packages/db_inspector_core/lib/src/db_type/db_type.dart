/// Abstract class representing a generic database type.
abstract class DB {
  /// The name of the database type.
  String get name;
  /// Establishes a connection to the database.
  Future<void> connect();
  /// Disconnects from the database.
  Future<void> disconnect();

  /// A stream that emits the number of properties in the database whenever there is a change.
  Stream<int> get noOfProperties;
}
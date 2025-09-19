/// Abstract class representing a generic database type.
abstract class DB {
  /// The name of the database type.
  String get name;
  /// Establishes a connection to the database.
  Future<void> connect();
  /// Disconnects from the database.
  Future<void> disconnect();

  /// A stream that emits an integer value whenever there is a change in the database.
  Stream<int> get onChange;
}
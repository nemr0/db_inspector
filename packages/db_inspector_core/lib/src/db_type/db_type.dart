/// Abstract class representing a generic database type.
abstract class DBType {
  /// The name of the database type.
  String get name;
  /// The version of the database type.
  String get version;
  /// Establishes a connection to the database.
  Future<void> connect();
  /// Disconnects from the database.
  Future<void> disconnect();
  /// Returns true if the database is connected.
  bool isConnected();
}
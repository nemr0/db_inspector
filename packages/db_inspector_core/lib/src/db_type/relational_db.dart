import 'db_type.dart';

/// Abstract class for interacting with a relational database.
abstract class RelationalDB extends DB {
  /// Executes the given SQL [query] with optional [params] and
  /// returns a list of rows (each row is a map of column names to values).
  Future<List<Map<String, dynamic>>> query(
    String sql,
    [List<dynamic>? params]
  );

  /// Executes a SQL command (e.g., INSERT/UPDATE/DELETE) with optional [params]
  /// and returns the number of affected rows.
  Future<int> execute(
    String sql,
    [List<dynamic>? params]
  );

  /// Returns a list of all table names in the database.
  Future<List<String>> getTables();

  /// Returns the schema for [tableName] as a map where keys are column names
  /// and values are their SQL data types.
  Future<Map<String, String>> getTableSchema(String tableName);
}
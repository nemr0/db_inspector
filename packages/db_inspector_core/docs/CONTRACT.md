# db_inspector_core Contract

This file describes the minimal adapter contract that db_inspector expects. See ../hive_db_inspector/lib for a concrete example.

Overview
- Adapter = code that lets db_inspector list containers, inspect entries, and perform basic ops.
- Supported models: Box (container holding keyed entries) and generic key–value stores.
- Future: SQL support via additional interfaces.

Core expectations (semantic summary)

DbInspector
- Purpose: top-level handle for a database instance.
- Key methods:
  - Future<List<String>> listContainers();
  - Future<ContainerInspector> openContainer(String name);
  - Future<void> close();

ContainerInspector
- Represents a container (box/table/collection).
- Key methods:
  - Future<int> count();
  - Future<List<EntryInfo>> entries({int? limit, int? offset});
  - Future<EntryInfo?> getByKey(String key);
  - Future<void> put(String key, dynamic value);
  - Future<void> delete(String key);
  - Stream<ChangeEvent> watch({String? key});

EntryInfo
- Fields:
  - String key;
  - dynamic value;
  - DateTime? createdAt;
  - DateTime? updatedAt;

ChangeEvent
- Types: added, updated, deleted
- Fields:
  - String key;
  - String type; // one of 'added'|'updated'|'deleted'
  - EntryInfo? entry; // new value when applicable

Implementation notes
- Serialization: adapters must deserialize values into Dart-friendly objects for display.
- Pagination: entries() should support limit/offset to avoid loading large datasets.
- Errors: throw clear exceptions for I/O/permission failures.
- Lifecycle: ensure resources (files/connections) are released in close().

Adapter discovery & registration
- Provide a factory function or class to create DbInspector instances:
  - Example: Future<DbInspector> createDbInspector(Map<String, dynamic> config)
- Document required config keys (path, credentials, options).

Extending for SQL
- Introduce SQL-specific inspector interfaces (e.g. listTables, runQuery) while keeping ContainerInspector semantics where applicable.
- Consider a QueryableInspector for query execution and schema inspection.

Testing recommendations
- Unit tests for all core methods and watch events.
- Integration tests with small fixtures; mirror the pattern used in ../hive_db_inspector.

This contract is intentionally minimal — keep method names and behaviors stable to avoid breaking adapters.


# db_inspector_core

db_inspector_core defines the stable contract (interfaces and expectations) for database adapters used by the db_inspector tools.

Goals
- Provide a minimal, stable contract for adapters.
- Support Box (Hive-style) and generic key–value stores initially.
- Allow future addition of SQL-style inspectors without breaking adapters.

Quick start
1. Read docs/CONTRACT.md to learn the required interfaces and lifecycle methods.
2. Use the reference adapter at ../hive_db_inspector/lib as an example implementation.
3. Implement the interfaces and expose a factory (e.g. createDbInspector(Map config)) so the host app can obtain your adapter.

Where to look
- Contract: docs/CONTRACT.md
- Reference implementation: ../hive_db_inspector/lib

Contributing & testing
- Add unit tests for listContainers, openContainer, entries, put, delete, and watch.
- Keep the public contract stable; document breaking changes clearly.


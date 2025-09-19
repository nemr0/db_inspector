# hive_db_inspector

hive_db_inspector provides a small integration layer that lets flutter_db_inspector inspect Hive boxes at runtime. It exposes opened Hive Box instances to the flutter_db_inspector UI so you can browse boxes, keys and values while your app runs.

What this package provides
- A HiveDB adapter (HiveDB) that implements the db type contract expected by flutter_db_inspector.
- A simple way to register one or more already-opened Hive boxes with the inspector.

How it works (high level)
1. Your app initializes Hive (for example, with Hive.initFlutter()).
2. You register all Hive type adapters required by your app before opening boxes.
3. You open your boxes (typed or untyped).
4. You create a HiveDB instance and provide the opened Box instances to it.
5. You pass that HiveDB instance into DbInspector (from flutter_db_inspector) via the dbTypes parameter.
6. DbInspector uses the supplied boxes to enumerate box names, keys and values and shows them in the inspector UI. Changes to boxes (adds/updates/deletes) are reflected live because Hive boxes are listenable.

Minimal usage (matches the example app)
- Initialize Hive and open boxes before creating the DbInspector:

  1. Initialize and register adapters:
     - await Hive.initFlutter();
     - Hive.registerAdapter(YourAdapter());

  2. Open boxes:
     - await Hive.openBox<T>('yourBoxName');

  3. Wrap your app with DbInspector:

     - Provide a navigatorKey (DbInspector uses it to push the inspector UI).
     - Create the HiveDB with the set of opened boxes and pass it to dbTypes.

  Example snippet (conceptual):
  - Ensure boxes are opened before constructing HiveDB:
    final box = Hive.box<T>('yourBoxName');
    DbInspector(
      navigatorKey: navigatorKey,
      dbTypes: [HiveDB(boxes: { box })],
      child: MaterialApp(...),
    );

API expectations
- HiveDB constructor:
  - Accepts a collection (set/iterable) of already-opened Hive Box instances.
  - The inspector reads box.name, enumerates keys and values, and listens to box changes.
- You are expected to:
  - Register Hive adapters before opening boxes.
  - Open boxes before passing them to HiveDB.
  - Provide a navigatorKey to DbInspector if you want inspector navigation to work.

What flutter_db_inspector shows
- List of boxes you provided.
- For each box: keys, values, and simple details (type, length).
- Ability to inspect and sometimes edit values depending on flutter_db_inspector capabilities.
- Live updates as boxes change (Hive's listenable boxes are used under the hood).

Tips and troubleshooting
- Adapter errors: If values display as raw bytes or cannot be decoded, ensure the correct TypeAdapter is registered prior to opening the box.
- Order of operations: Always register adapters, then open boxes, then construct HiveDB/DbInspector.
- Hot reload: Hive boxes are long-lived. If you change adapters or data structures during development you may need to restart the app and re-open boxes to avoid deserialization issues.
- Web support: When running on web, Hive uses different storage backends. Hive.initFlutter() is cross-platform and recommended.
- Closing boxes: If your app opens/closes boxes dynamically, make sure to update the HiveDB instance or re-create the inspector registration so the UI reflects the current set of boxes.

Where to look next
- Example app: packages/flutter_db_inspector/example/lib/main.dart demonstrates a full working setup with a Todo model, adapter registration, box opening, and registering HiveDB with DbInspector.
- flutter_db_inspector package: check its lib/ folder for the DbInspector API and UI capabilities.

License and contributions
- This README documents usage. For code-level details, open the package sources and the example. Contributions and fixes are welcome via pull requests.

````

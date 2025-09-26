import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences_db_inspector/shared_preferences_db_inspector.dart';

import 'models/todos.dart';
import 'package:flutter_db_inspector/flutter_db_inspector.dart';
import 'package:hive_db_inspector/hive_db_insepctor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Works on Android/iOS/macOS/Linux/Windows/Web
  await Hive.initFlutter();

  // Register adapters *before* opening boxes
  Hive.registerAdapter(TodoAdapter());

  // Open a typed box
  await Hive.openBox<Todo>('todos');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DbInspector(
      navigatorKey: navigatorKey,
      dbTypes: [HiveDB(boxes: {
        Hive.box<Todo>('todos')
      }),
      SharedPreferencesDbInspector(),
      ],
      child: MaterialApp(
        title: 'Hive Todos',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        navigatorKey: navigatorKey,
        home: const TodoPage(),
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _controller = TextEditingController();
  late final Box<Todo> _box;

  @override
  void initState() {

    super.initState();
    _box = Hive.box<Todo>('todos');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await _box.add(Todo(title: text));
    _controller.clear();
  }

  Future<void> _toggleDone(Todo todo) async {
    todo.done = !todo.done;
    await todo.save(); // because Todo extends HiveObject
  }

  Future<void> _renameTodo(Todo todo) async {
    final controller = TextEditingController(text: todo.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (newTitle != null && newTitle.isNotEmpty && newTitle != todo.title) {
      todo.title = newTitle;
      await todo.save();
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    await todo.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hive Todos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a todo…',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _addTodo,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box<Todo>>(
              valueListenable: _box.listenable(),
              builder: (context, box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('No todos yet. Add one!'));
                }

                // Read items by index for stable order
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final todo = box.getAt(index);
                    if (todo == null) return const SizedBox.shrink();

                    return Dismissible(
                      key: ValueKey(todo.key),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 16),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteTodo(todo),
                      child: ListTile(
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.done
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.done
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(150)
                                : null,
                          ),
                        ),
                        leading: Checkbox(
                          value: todo.done,
                          onChanged: (_) => _toggleDone(todo),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _renameTodo(todo),
                          tooltip: 'Rename',
                        ),
                        onTap: () => _toggleDone(todo),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:hive/hive.dart';

part 'todos.g.dart'; // <- not used here, but keeping the line is harmless
// If you choose to use code generation later, this file name matches.

@HiveType(typeId: 1) // Make sure this is unique in your app
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool done;

  Todo({required this.title, this.done = false});

  @override
  String toString() => 'Todo(title: $title, done: $done)';
}

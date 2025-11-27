import 'package:flutter_db_inspector/flutter_db_inspector.dart';
import 'package:hive/hive.dart';

part 'todos.g.dart'; // <- not used here, but keeping the line is harmless
// If you choose to use code generation later, this file name matches.

@HiveType(typeId: 1) // Make sure this is unique in your app
class Todo extends HiveObject with Serialized {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool done;
  dynamic get id => key;
  Todo({required this.title, this.done = false});

  @override
  String toString() => 'Todo(title: $title, done: $done)';

  @override
  Todo fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'] as String,
      done: json['done'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
    };
  }

}


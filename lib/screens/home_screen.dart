import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/task.dart';
import '../services/db_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Task> tasks = [];
  String? _selectedCategory;
  String? _description;
  final TextEditingController _descController = TextEditingController();

  final List<String> _categories = [
    'Work',
    'Personal',
    'Urgent',
    'Health',
    'Other',
  ];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    //_initializeNotifications();
    _loadTasks();
  }

  void _loadTasks() async {
    final data = await DBService.getTasks();
    setState(() {
      tasks = data;
    });
  }

  void _addTask(String title) async {
    if (title.trim().isEmpty) return;

    final newTask = Task(
      title: title,
      description: _descController.text.trim(),
      category: _selectedCategory,
    );

    await DBService.insertTask(newTask);
    _controller.clear();
    _descController.clear(); // ✅ Clears description
    _description = null;
    _selectedCategory = null;
    _loadTasks();

    //final reminderTime = DateTime.now().add(const Duration(hours: 1));
    //scheduleReminder(title, reminderTime);
  }

  void _deleteTask(int id) async {
    await DBService.deleteTask(id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My To-Do List"),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => _description = value,
                  controller: _descController, // ✅ add this

                  decoration: const InputDecoration(
                    hintText: 'Task Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text("Select Category"),
                  items: _categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Task"),
                  onPressed: () => _addTask(_controller.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) {
                final task = tasks[i];
                return ListTile(
                  tileColor: task.isDone
                      ? Colors.green.shade100
                      : (isDark ? Colors.grey[800] : Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (_) async {
                      setState(() {
                        task.isDone = !task.isDone;
                      });
                      await DBService.updateTask(task);
                    },
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone
                              ? Colors.grey
                              : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      if (task.description != null &&
                          task.description!.isNotEmpty)
                        MarkdownBody(data: task.description!),

                      // Text(
                      //   task.description!,
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: isDark ? Colors.grey[300] : Colors.grey[800],
                      //   ),
                      // ),
                      if (task.category != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            'Category: ${task.category}',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteTask(task.id!),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

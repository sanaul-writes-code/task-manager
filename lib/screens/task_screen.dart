import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();

    if (title.isEmpty) return;

    try {
      await _taskService.addTask(title);
      _taskController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding task: $e')));
    }
  }

  Future<void> _toggleTask(Task task) async {
    try {
      await _taskService.toggleTask(task);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating task: $e')));
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
    }
  }

  Widget _buildSubtaskSection(Task task) {
    final TextEditingController subtaskController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: subtaskController,
                  decoration: const InputDecoration(hintText: 'Add subtask...'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final text = subtaskController.text.trim();
                  if (text.isEmpty) return;

                  await _taskService.addSubtask(task, text);
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (task.subtasks.isEmpty)
            const Text('No subtasks')
          else
            Column(
              children: List.generate(task.subtasks.length, (index) {
                final subtask = task.subtasks[index];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(subtask),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _taskService.deleteSubtask(task, index),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteTask(String taskId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteTask(taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Enter a task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _addTask, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: _taskService.streamTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Something went wrong:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final tasks = snapshot.data ?? [];

                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tasks yet',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (_) => _toggleTask(task),
                              ),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmDeleteTask(task.id),
                              ),
                            ],
                          ),
                          children: [_buildSubtaskSection(task)],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

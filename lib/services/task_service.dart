import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection('tasks');

  // Create task
  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    await _tasksCollection.add({
      'title': title.trim(),
      'isCompleted': false,
      'subtasks': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  //Read task
  Stream<List<Task>> streamTasks() {
    return _tasksCollection.orderBy('createdAt').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Update task
  Future<void> toggleTask(Task task) async {
    await _tasksCollection.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  // Add subtask
  Future<void> addSubtask(Task task, String subtask) async {
    if (subtask.trim().isEmpty) return;

    final updatedSubtasks = List<String>.from(task.subtasks)
      ..add(subtask.trim());

    await _tasksCollection.doc(task.id).update({'subtasks': updatedSubtasks});
  }

  // Delete subtask
  Future<void> deleteSubtask(Task task, int index) async {
    final updatedSubtasks = List<String>.from(task.subtasks)..removeAt(index);

    await _tasksCollection.doc(task.id).update({'subtasks': updatedSubtasks});
  }
}

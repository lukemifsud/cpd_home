import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskController = TextEditingController();

  //reference to firebase database
  final DatabaseReference _tasksRef = FirebaseDatabase.instance.ref('tasks');

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration
              (labelText: 'Task'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                 final taskText = _taskController.text.trim();
                 if (taskText.isNotEmpty) {
                   
                  Navigator.pop(context);
                  
                  _tasksRef.push().set(taskText);
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
                     
  }
}
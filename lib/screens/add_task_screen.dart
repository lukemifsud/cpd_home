//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay? _timeOfDay;

  // Callback-style function to pick a time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _timeOfDay) {
      setState(() {
        _timeOfDay = picked;
      });
    }
  }

  // Non-async version of _addTask
  void _addTask() {
    final String taskText = _taskController.text.trim();
    if (taskText.isEmpty || _timeOfDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task and select a time.')),
      );
      return;
    }

    final String formattedTime = _timeOfDay!.format(context);
    final int timeValue = _timeOfDay!.hour * 60 + _timeOfDay!.minute;

    // Basic task data (without location yet)
    final Map<String, dynamic> taskData = {
      'description': taskText,
      'time': formattedTime,
      'timeValue': timeValue,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // 1. Get the current location
    getCurrentLocation().then((position) {
      if (!mounted) return; // check if widget is still mounted

      // 2. Attach latitude/longitude
      taskData['latitude'] = position.latitude;
      taskData['longitude'] = position.longitude;

      // 3. Push to Firebase Realtime Database
      final DatabaseReference tasksRef = FirebaseDatabase.instance.ref('tasks');
      tasksRef.push().set(taskData).then((_) {
        if (!mounted) return;

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $error')),
        );
      });
    }).catchError((error) {
      // If getCurrentLocation() failed or user denied permissions
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: const InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _timeOfDay == null
                        ? 'No Time Selected'
                        : 'Time: ${_timeOfDay!.format(context)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: const Text('Select Time'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTask,
                child: const Text('Add Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Our location helper method
Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission denied forever.');
  }

  return await Geolocator.getCurrentPosition();
}

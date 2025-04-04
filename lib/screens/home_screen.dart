import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  final List<String> tasks = [];

  @override
Widget build(BuildContext context) {
  final Query tasksQuery = FirebaseDatabase.instance.ref('tasks').orderByChild('timeValue');

  return Scaffold(
    backgroundColor: Color.fromARGB(255, 2, 20, 99),
    appBar: AppBar(
      centerTitle: true,
      title: const Text('To-Do List')),
    body: StreamBuilder<DatabaseEvent>(
      stream: tasksQuery.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No tasks added!'));
        }

        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final List<MapEntry<dynamic, dynamic>> taskEntries = data.entries.toList();

        // Sort by timeValue if desired
        taskEntries.sort((a, b) {
          final int timeA = a.value['timeValue'] ?? 0;
          final int timeB = b.value['timeValue'] ?? 0;
          return timeA.compareTo(timeB);
        });

        return ListView.separated(
          itemCount: taskEntries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final task = taskEntries[index].value;
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.task_alt),
                title: Text(
                  task['description'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Time: ${task['time'] ?? ''}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    FirebaseDatabase.instance
                        .ref('tasks')
                        .child(taskEntries[index].key)
                        .remove();
                  },
                ),
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/add_task'),
      label: const Text('Add New Task'),
      icon: const Icon(Icons.add),
    ),
  );
}

 
}
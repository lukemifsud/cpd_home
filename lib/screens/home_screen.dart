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
    // Create a query that orders tasks by the 'timeValue' field.
    final Query tasksQuery =
        FirebaseDatabase.instance.ref('tasks').orderByChild('timeValue');

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
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

          // The snapshot data is typically a Map of tasks.
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          // Convert the map entries to a list.
          final List<MapEntry<dynamic, dynamic>> taskEntries =
              data.entries.toList();
          
          // They should already be ordered by 'timeValue' because of the query.
          // Optionally, you can sort again just to be sure:
          taskEntries.sort((a, b) {
            final int timeA = a.value['timeValue'] ?? 0;
            final int timeB = b.value['timeValue'] ?? 0;
            return timeA.compareTo(timeB);
          });

          return ListView.builder(
            itemCount: taskEntries.length,
            itemBuilder: (context, index) {
              final task = taskEntries[index].value;
              return ListTile(
                title: Text(task['description'] ?? ''),
                subtitle: Text('Time: ${task['time'] ?? ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Remove task by its unique key.
                    FirebaseDatabase.instance
                        .ref('tasks')
                        .child(taskEntries[index].key)
                        .remove();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_task');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
 
}
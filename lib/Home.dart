import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final fetchedTasks = await DatabaseHelper.instance.fetchTasks();
    setState(() {
      tasks = fetchedTasks;
    });
  }

  Future<void> _addTask(String title, String description) async {
    final newTask = Task(title: title, description: description);
    await DatabaseHelper.instance.insertTask(newTask);
    _loadTasks();
  }

  Future<void> _editTask(int index, String title, String description) async {
    final updatedTask =
        Task(id: tasks[index].id, title: title, description: description);
    await DatabaseHelper.instance.updateTask(updatedTask);
    _loadTasks();
  }

  Future<void> _deleteTask(int index) async {
    await DatabaseHelper.instance.deleteTask(tasks[index].id!);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle listItemTextStyle = TextStyle(
      fontFamily: 'Arial',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 8),
            Text(
              'MY TODO LIST',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.calendar_today),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 192, 237, 215),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ListTile(
              title: Text(
                tasks[index].title,
                style: listItemTextStyle,
              ),
              subtitle: Text(
                tasks[index].description,
                style: listItemTextStyle,
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.black),
                    onPressed: () => _showEditTaskDialog(context, index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.black),
                    onPressed: () => _deleteTask(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    String title = '';
    String description = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  title = value;
                },
                decoration: InputDecoration(hintText: 'Title'),
              ),
              TextField(
                onChanged: (value) {
                  description = value;
                },
                decoration: InputDecoration(hintText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && description.isNotEmpty) {
                  _addTask(title, description);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditTaskDialog(BuildContext context, int index) async {
    TextEditingController titleController =
        TextEditingController(text: tasks[index].title);
    TextEditingController descriptionController =
        TextEditingController(text: tasks[index].description);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  _editTask(
                      index, titleController.text, descriptionController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

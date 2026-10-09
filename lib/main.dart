import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Smart To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class Task {
  String title;
  String priority;
  bool completed;

  Task({
    required this.title,
    required this.priority,
    this.completed = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  void addTask(String title, String priority) {
    setState(() {
      tasks.add(Task(title: title, priority: priority));
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void clearAllTasks() {
    setState(() {
      tasks.clear();
    });
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
    });
  }

  void showAddTaskDialog() {
    final titleController = TextEditingController();
    String selectedPriority = 'Medium';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add New Task',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Task name',
                        hintText: 'Enter your task',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Low', 'Medium', 'High']
                          .map(
                            (priority) => DropdownMenuItem<String>(
                              value: priority,
                              child: Text(priority),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedPriority = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    titleController.dispose();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a task name',
                          ),
                        ),
                      );
                      return;
                    }

                    addTask(
                      titleController.text.trim(),
                      selectedPriority,
                    );

                    titleController.dispose();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color getPriorityColor(String priority) {
    if (priority == 'High') {
      return Colors.red;
    } else if (priority == 'Medium') {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget buildSummaryItem(
    IconData icon,
    String count,
    String label,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskCard(Task task) {
    final originalIndex = tasks.indexOf(task);
    final priorityColor = getPriorityColor(task.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) => toggleTask(originalIndex),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: task.completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.completed ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.priority,
              style: TextStyle(
                color: priorityColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        trailing: IconButton(
          tooltip: 'Delete task',
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
          onPressed: () => deleteTask(originalIndex),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive UI: get the available screen width.
    final screenWidth = MediaQuery.of(context).size.width;

    final contentMaxWidth =
        screenWidth >= 1000 ? 1000.0 : screenWidth;

    final completedCount =
        tasks.where((task) => task.completed).length;

    final pendingCount = tasks.length - completedCount;

    final filteredTasks = tasks.where((task) {
      return task.title
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text(
          'My Smart To-Do List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All Tasks',
            onPressed: () {
              if (tasks.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('There are no tasks to clear'),
                  ),
                );
                return;
              }

              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Clear all tasks?'),
                  content: const Text(
                    'This will remove every task from the list.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        clearAllTasks();
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddTaskDialog,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: contentMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            // LayoutBuilder adapts the task layout to available width.
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen =
                    constraints.maxWidth >= 700;

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          buildSummaryItem(
                            Icons.list_alt,
                            '${tasks.length}',
                            'Total',
                          ),
                          buildSummaryItem(
                            Icons.pending_actions,
                            '$pendingCount',
                            'Pending',
                          ),
                          buildSummaryItem(
                            Icons.check_circle,
                            '$completedCount',
                            'Completed',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchText.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {
                                    searchText = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'My Tasks',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredTasks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 70,
                                    color: Colors.indigo,
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    searchText.isEmpty
                                        ? 'No tasks yet!'
                                        : 'No matching tasks found!',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    searchText.isEmpty
                                        ? 'Tap "Add Task" to create your first task.'
                                        : 'Try searching for another task.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              itemCount: filteredTasks.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    isWideScreen ? 2 : 1,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 0,
                                childAspectRatio:
                                    isWideScreen ? 3.0 : 4.2,
                              ),
                              itemBuilder: (context, index) {
                                return buildTaskCard(
                                  filteredTasks[index],
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
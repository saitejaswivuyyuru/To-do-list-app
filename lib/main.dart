import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TodoApp());
}

// TASK MODEL
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

// MAIN APP
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart To-Do List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// HOME SCREEN
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

  int get completedCount =>
      tasks.where((task) => task.completed).length;

  int get pendingCount =>
      tasks.where((task) => !task.completed).length;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void addTask(String title, String priority) {
    setState(() {
      tasks.add(
        Task(
          title: title,
          priority: priority,
        ),
      );
    });
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted'),
      ),
    );
  }

  // ADD TASK FORM WITH VALIDATION
  Future<void> showAddTaskDialog() async {
    final titleController = TextEditingController();
    String selectedPriority = 'Medium';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      hintText: 'Enter your task',
                      prefixIcon: Icon(Icons.edit_note),
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
                    items: const [
                      DropdownMenuItem(
                        value: 'Low',
                        child: Text('Low'),
                      ),
                      DropdownMenuItem(
                        value: 'Medium',
                        child: Text('Medium'),
                      ),
                      DropdownMenuItem(
                        value: 'High',
                        child: Text('High'),
                      ),
                    ],
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
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final title =
                        titleController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a task title',
                          ),
                        ),
                      );
                      return;
                    }

                    addTask(title, selectedPriority);

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(this.context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Task added successfully',
                        ),
                      ),
                    );
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
  }

  // CLEAR ALL TASKS
  Future<void> clearAllTasks() async {
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There are no tasks to clear'),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear All Tasks?'),
          content: const Text(
            'Are you sure you want to delete all tasks?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        tasks.clear();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All tasks cleared'),
        ),
      );
    }
  }

  // PRIORITY COLORS
  Color priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange.shade800;
      default:
        return Colors.green;
    }
  }

  // SUMMARY WIDGET
  Widget buildSummaryItem(
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // TASK CARD
  Widget buildTaskCard(Task task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: task.completed,
              onChanged: (_) {
                toggleTask(tasks.indexOf(task));
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.completed
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor(task.priority)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${task.priority} Priority',
                      style: TextStyle(
                        color: priorityColor(task.priority),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete task',
              onPressed: () {
                deleteTask(tasks.indexOf(task));
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = tasks.where((task) {
      return task.title
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart To-Do List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'API Tasks',
            icon: const Icon(Icons.cloud_download_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ApiTasksScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Statistics',
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatisticsScreen(
                    tasks: tasks,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Clear all tasks',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: clearAllTasks,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth > 1000
                    ? 1000.0
                    : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ANIMATED WELCOME BANNER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3949AB),
                              Color(0xFF7986CB),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ),
                              duration: const Duration(
                                seconds: 3,
                              ),
                              curve: Curves.easeOut,
                              builder: (
                                context,
                                value,
                                child,
                              ) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      40 * (1 - value),
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                              child: const Text(
                                'Stay Organized!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Plan your day and achieve your goals.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // TASK SUMMARY
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 8,
                          ),
                          child: Row(
                            children: [
                              buildSummaryItem(
                                'Total',
                                tasks.length,
                                Icons.checklist,
                                Colors.indigo,
                              ),
                              buildSummaryItem(
                                'Pending',
                                pendingCount,
                                Icons.pending_actions,
                                Colors.orange,
                              ),
                              buildSummaryItem(
                                'Completed',
                                completedCount,
                                Icons.task_alt,
                                Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // SEARCH
                      TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search your tasks...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchText.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      searchText = '';
                                    });
                                  },
                                  icon: const Icon(Icons.clear),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // TASK LIST TITLE
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Tasks',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${filteredTasks.length} tasks',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (filteredTasks.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                Icon(
                                  searchText.isEmpty
                                      ? Icons.format_list_bulleted
                                      : Icons.search_off,
                                  size: 55,
                                  color: Colors.indigo.shade200,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  searchText.isEmpty
                                      ? 'No tasks yet!'
                                      : 'No matching tasks found',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Add a task to get started.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (
                            context,
                            taskConstraints,
                          ) {
                            final cardWidth =
                                taskConstraints.maxWidth >= 700
                                    ? (taskConstraints.maxWidth -
                                            12) /
                                        2
                                    : taskConstraints.maxWidth;

                            return Wrap(
                              spacing: 12,
                              children: filteredTasks.map((task) {
                                return SizedBox(
                                  width: cardWidth,
                                  child: buildTaskCard(task),
                                );
                              }).toList(),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

// STATISTICS SCREEN
class StatisticsScreen extends StatelessWidget {
  final List<Task> tasks;

  const StatisticsScreen({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final completed =
        tasks.where((task) => task.completed).length;
    final pending = total - completed;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Statistics'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.insights,
                size: 70,
                color: Colors.indigo,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your Productivity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track your progress and stay motivated.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const Text(
                        'Completion Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor:
                                  Colors.indigo.shade100,
                              color: Colors.indigo,
                            ),
                            Center(
                              child: Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$completed of $total tasks completed',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _statCard(
                'Total Tasks',
                total,
                Icons.checklist,
                Colors.indigo,
              ),
              _statCard(
                'Completed Tasks',
                completed,
                Icons.task_alt,
                Colors.green,
              ),
              _statCard(
                'Pending Tasks',
                pending,
                Icons.pending_actions,
                Colors.orange,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to My Tasks'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

// REST API SCREEN
class ApiTasksScreen extends StatefulWidget {
  const ApiTasksScreen({super.key});

  @override
  State<ApiTasksScreen> createState() =>
      _ApiTasksScreenState();
}

class _ApiTasksScreenState extends State<ApiTasksScreen> {
  List<dynamic> apiTasks = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://jsonplaceholder.typicode.com/todos?_limit=10',
            ),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body) as List<dynamic>;

        if (!mounted) return;

        setState(() {
          apiTasks = data;
          isLoading = false;
        });
      } else {
        throw Exception(
          'Server returned ${response.statusCode}',
        );
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Unable to load tasks. Check your internet connection.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online API Tasks'),
        actions: [
          IconButton(
            tooltip: 'Refresh tasks',
            onPressed: fetchTasks,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading tasks from API...'),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          size: 50,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: fetchTasks,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : apiTasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks received from the API.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: apiTasks.length,
                      itemBuilder: (context, index) {
                        final task = apiTasks[index];
                        final bool completed =
                            task['completed'] == true;

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: completed
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              child: Icon(
                                completed
                                    ? Icons.check
                                    : Icons.pending_actions,
                                color: completed
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            title: Text(
                              task['title']?.toString() ??
                                  'Untitled task',
                            ),
                            subtitle: Text(
                              'Task ID: ${task['id']}',
                            ),
                            trailing: Text(
                              completed
                                  ? 'Completed'
                                  : 'Pending',
                              style: TextStyle(
                                color: completed
                                    ? Colors.green
                                    : Colors.orange.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
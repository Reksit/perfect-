import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class Task {
  final String id;
  final String taskName;
  final String description;
  final DateTime dueDate;
  final String status; // PENDING, IN_PROGRESS, COMPLETED, OVERDUE
  final List<String> roadmap;
  final bool roadmapGenerated;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.taskName,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.roadmap,
    required this.roadmapGenerated,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      taskName: json['taskName'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'],
      roadmap: List<String>.from(json['roadmap'] ?? []),
      roadmapGenerated: json['roadmapGenerated'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  List<Task> _tasks = [];
  bool _loading = true;
  bool _showCreateForm = false;
  final Set<String> _expandedTasks = {};
  String? _generatingRoadmap;

  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
    });

    try {
      // Simulate API call with sample data
      await Future.delayed(const Duration(seconds: 1));

      _tasks = [
        Task(
          id: '1',
          taskName: 'Complete Data Structures Assignment',
          description: 'Implement binary search tree with insert, delete, and search operations',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          status: 'IN_PROGRESS',
          roadmap: [
            'Research binary search tree concepts',
            'Design the tree structure',
            'Implement insert operation',
            'Implement search operation',
            'Implement delete operation',
            'Write test cases',
            'Submit assignment'
          ],
          roadmapGenerated: true,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Task(
          id: '2',
          taskName: 'Prepare for Database Exam',
          description: 'Study SQL queries, normalization, and transaction management',
          dueDate: DateTime.now().add(const Duration(days: 14)),
          status: 'PENDING',
          roadmap: [
            'Review SQL basics',
            'Practice complex queries',
            'Study normalization forms',
            'Understand ACID properties',
            'Practice with sample questions',
            'Take practice exam'
          ],
          roadmapGenerated: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Task(
          id: '3',
          taskName: 'Job Application Follow-up',
          description: 'Follow up on submitted applications and prepare for interviews',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          status: 'PENDING',
          roadmap: [],
          roadmapGenerated: false,
          createdAt: DateTime.now(),
        ),
      ];

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load tasks: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createTask() async {
    if (_taskNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dueDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskName: _taskNameController.text,
        description: _descriptionController.text,
        dueDate: DateTime.parse(_dueDateController.text),
        status: 'PENDING',
        roadmap: [],
        roadmapGenerated: false,
        createdAt: DateTime.now(),
      );

      setState(() {
        _tasks.insert(0, newTask);
        _showCreateForm = false;
      });

      _taskNameController.clear();
      _descriptionController.clear();
      _dueDateController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create task: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateTaskStatus(Task task, String newStatus) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = Task(
            id: task.id,
            taskName: task.taskName,
            description: task.description,
            dueDate: task.dueDate,
            status: newStatus,
            roadmap: task.roadmap,
            roadmapGenerated: task.roadmapGenerated,
            createdAt: task.createdAt,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task status updated to ${newStatus.toLowerCase()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update task: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateRoadmap(Task task) async {
    setState(() {
      _generatingRoadmap = task.id;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Generate AI roadmap based on task description
      final roadmap = _generateAIRoadmap(task.taskName, task.description);

      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = Task(
            id: task.id,
            taskName: task.taskName,
            description: task.description,
            dueDate: task.dueDate,
            status: task.status,
            roadmap: roadmap,
            roadmapGenerated: true,
            createdAt: task.createdAt,
          );
        }
        _generatingRoadmap = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Roadmap generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _generatingRoadmap = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate roadmap: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<String> _generateAIRoadmap(String taskName, String description) {
    // Simple AI roadmap generation based on keywords
    if (description.toLowerCase().contains('assignment') ||
        description.toLowerCase().contains('homework')) {
      return [
        'Research and understand requirements',
        'Plan the solution approach',
        'Break down into smaller components',
        'Implement core functionality',
        'Test and debug',
        'Document the solution',
        'Review and finalize submission'
      ];
    } else if (description.toLowerCase().contains('exam') ||
             description.toLowerCase().contains('test')) {
      return [
        'Review course materials',
        'Identify key topics',
        'Create study schedule',
        'Practice with exercises',
        'Take practice tests',
        'Review weak areas',
        'Final preparation'
      ];
    } else if (description.toLowerCase().contains('job') ||
             description.toLowerCase().contains('interview')) {
      return [
        'Research the company',
        'Update resume and portfolio',
        'Practice common interview questions',
        'Prepare specific examples',
        'Plan interview day logistics',
        'Follow up after interview'
      ];
    } else {
      return [
        'Define clear objectives',
        'Research and gather information',
        'Create action plan',
        'Execute planned steps',
        'Monitor progress',
        'Make necessary adjustments',
        'Complete and review'
      ];
    }
  }

  void _toggleTaskExpansion(String taskId) {
    setState(() {
      if (_expandedTasks.contains(taskId)) {
        _expandedTasks.remove(taskId);
      } else {
        _expandedTasks.add(taskId);
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'OVERDUE':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'IN_PROGRESS':
        return Icons.schedule;
      case 'OVERDUE':
        return Icons.warning;
      default:
        return Icons.pending;
    }
  }

  String _getTimeUntilDue(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    } else {
      return 'Due soon';
    }
  }

  Widget _buildCreateTaskForm() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Create New Task',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showCreateForm = false;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.task),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _dueDateController,
              decoration: const InputDecoration(
                labelText: 'Due Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  _dueDateController.text = date.toIso8601String().split('T')[0];
                }
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () {
                      setState(() {
                        _showCreateForm = false;
                      });
                    },
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Create Task',
                    onPressed: _createTask,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isExpanded = _expandedTasks.contains(task.id);
    final isGenerating = _generatingRoadmap == task.id;

    return CustomCard(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _getStatusIcon(task.status),
              color: _getStatusColor(task.status),
            ),
            title: Text(
              task.taskName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeUntilDue(task.dueDate),
                      style: TextStyle(
                        color: task.dueDate.isBefore(DateTime.now()) 
                            ? Colors.red 
                            : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () => _toggleTaskExpansion(task.id),
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            ),
          ),
          
          if (isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status update buttons
                  Text(
                    'Update Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['PENDING', 'IN_PROGRESS', 'COMPLETED'].map((status) =>
                      FilterChip(
                        label: Text(status.replaceAll('_', ' ')),
                        selected: task.status == status,
                        onSelected: task.status != status 
                            ? (selected) => _updateTaskStatus(task, status)
                            : null,
                        selectedColor: _getStatusColor(status).withOpacity(0.3),
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Roadmap section
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Roadmap',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!task.roadmapGenerated && !isGenerating)
                        TextButton.icon(
                          onPressed: () => _generateRoadmap(task),
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate AI Roadmap'),
                        ),
                      if (isGenerating)
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Generating...'),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (task.roadmap.isNotEmpty)
                    ...task.roadmap.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(step)),
                          ],
                        ),
                      );
                    })
                  else if (!task.roadmapGenerated && !isGenerating)
                    const Text(
                      'No roadmap available. Generate one using AI!',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadTasks,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_showCreateForm) ...[
                    _buildCreateTaskForm(),
                    const SizedBox(height: 16),
                  ],
                  
                  if (_tasks.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your first task to get started!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ...List.generate(_tasks.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildTaskCard(_tasks[index]),
                      );
                    }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showCreateForm = !_showCreateForm;
          });
        },
        icon: Icon(_showCreateForm ? Icons.close : Icons.add),
        label: Text(_showCreateForm ? 'Cancel' : 'Add Task'),
      ),
    );
  }
}

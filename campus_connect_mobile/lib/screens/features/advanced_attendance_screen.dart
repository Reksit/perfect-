import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/custom_card.dart';

class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String courseId;
  final String courseName;
  final DateTime date;
  final String status; // PRESENT, ABSENT, LATE, EXCUSED
  final String? reason;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.status,
    this.reason,
    this.checkInTime,
    this.checkOutTime,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      courseId: json['courseId'],
      courseName: json['courseName'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      reason: json['reason'],
      checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime']) : null,
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime']) : null,
    );
  }
}

class AttendanceStats {
  final int totalClasses;
  final int presentClasses;
  final int absentClasses;
  final int lateClasses;
  final int excusedClasses;
  final double attendancePercentage;

  AttendanceStats({
    required this.totalClasses,
    required this.presentClasses,
    required this.absentClasses,
    required this.lateClasses,
    required this.excusedClasses,
    required this.attendancePercentage,
  });
}

class AdvancedAttendanceScreen extends StatefulWidget {
  const AdvancedAttendanceScreen({super.key});

  @override
  State<AdvancedAttendanceScreen> createState() => _AdvancedAttendanceScreenState();
}

class _AdvancedAttendanceScreenState extends State<AdvancedAttendanceScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<AttendanceRecord> _attendanceRecords = [];
  Map<String, AttendanceStats> _courseStats = {};
  bool _loading = true;
  String _selectedPeriod = 'thisMonth';
  String _selectedCourse = 'all';

  final List<String> _periods = ['thisWeek', 'thisMonth', 'thisYear', 'all'];
  final List<String> _courses = ['all', 'CS101', 'CS102', 'MATH201', 'ENG101'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _loading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Generate sample attendance data
      _attendanceRecords = _generateSampleAttendanceData();
      _courseStats = _calculateCourseStats();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load attendance data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<AttendanceRecord> _generateSampleAttendanceData() {
    final records = <AttendanceRecord>[];
    final courses = ['CS101', 'CS102', 'MATH201', 'ENG101'];
    final statuses = ['PRESENT', 'ABSENT', 'LATE', 'EXCUSED'];
    
    for (int i = 0; i < 60; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final course = courses[i % courses.length];
      final status = statuses[
        i < 45 ? 0 : // Most present
        i < 50 ? 1 : // Some absent
        i < 55 ? 2 : // Some late
        3            // Some excused
      ];

      records.add(AttendanceRecord(
        id: 'att_$i',
        studentId: 'student_1',
        studentName: 'John Doe',
        courseId: course,
        courseName: _getCourseName(course),
        date: date,
        status: status,
        reason: status == 'ABSENT' ? 'Sick' : status == 'EXCUSED' ? 'Family emergency' : null,
        checkInTime: status == 'PRESENT' || status == 'LATE' 
            ? date.add(Duration(hours: 9, minutes: status == 'LATE' ? 15 : 0))
            : null,
        checkOutTime: status == 'PRESENT' || status == 'LATE' 
            ? date.add(Duration(hours: 10, minutes: 30))
            : null,
      ));
    }

    return records;
  }

  String _getCourseName(String courseId) {
    switch (courseId) {
      case 'CS101':
        return 'Introduction to Programming';
      case 'CS102':
        return 'Data Structures';
      case 'MATH201':
        return 'Calculus II';
      case 'ENG101':
        return 'English Composition';
      default:
        return courseId;
    }
  }

  Map<String, AttendanceStats> _calculateCourseStats() {
    final stats = <String, AttendanceStats>{};
    
    for (final course in _courses.where((c) => c != 'all')) {
      final courseRecords = _attendanceRecords.where((r) => r.courseId == course).toList();
      
      final present = courseRecords.where((r) => r.status == 'PRESENT').length;
      final absent = courseRecords.where((r) => r.status == 'ABSENT').length;
      final late = courseRecords.where((r) => r.status == 'LATE').length;
      final excused = courseRecords.where((r) => r.status == 'EXCUSED').length;
      final total = courseRecords.length;
      
      stats[course] = AttendanceStats(
        totalClasses: total,
        presentClasses: present,
        absentClasses: absent,
        lateClasses: late,
        excusedClasses: excused,
        attendancePercentage: total > 0 ? (present + late) / total * 100 : 0,
      );
    }

    return stats;
  }

  List<AttendanceRecord> get _filteredRecords {
    var records = _attendanceRecords;

    // Filter by course
    if (_selectedCourse != 'all') {
      records = records.where((r) => r.courseId == _selectedCourse).toList();
    }

    // Filter by period
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'thisWeek':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        records = records.where((r) => r.date.isAfter(startOfWeek)).toList();
        break;
      case 'thisMonth':
        final startOfMonth = DateTime(now.year, now.month, 1);
        records = records.where((r) => r.date.isAfter(startOfMonth)).toList();
        break;
      case 'thisYear':
        final startOfYear = DateTime(now.year, 1, 1);
        records = records.where((r) => r.date.isAfter(startOfYear)).toList();
        break;
    }

    return records;
  }

  Widget _buildOverviewTab() {
    final filteredRecords = _filteredRecords;
    final totalClasses = filteredRecords.length;
    final presentClasses = filteredRecords.where((r) => r.status == 'PRESENT').length;
    final absentClasses = filteredRecords.where((r) => r.status == 'ABSENT').length;
    final lateClasses = filteredRecords.where((r) => r.status == 'LATE').length;
    final excusedClasses = filteredRecords.where((r) => r.status == 'EXCUSED').length;
    final attendancePercentage = totalClasses > 0 ? (presentClasses + lateClasses) / totalClasses * 100 : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    border: OutlineInputBorder(),
                  ),
                  items: _periods.map((period) => DropdownMenuItem(
                    value: period,
                    child: Text(_getPeriodLabel(period)),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCourse,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    border: OutlineInputBorder(),
                  ),
                  items: _courses.map((course) => DropdownMenuItem(
                    value: course,
                    child: Text(course == 'all' ? 'All Courses' : course),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overall Statistics
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Attendance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: presentClasses.toDouble(),
                              title: 'Present\n$presentClasses',
                              color: Colors.green,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: absentClasses.toDouble(),
                              title: 'Absent\n$absentClasses',
                              color: Colors.red,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: lateClasses.toDouble(),
                              title: 'Late\n$lateClasses',
                              color: Colors.orange,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: excusedClasses.toDouble(),
                              title: 'Excused\n$excusedClasses',
                              color: Colors.blue,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          centerSpaceRadius: 60,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Attendance Rate: ${attendancePercentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: attendancePercentage >= 75 ? Colors.green : 
                             attendancePercentage >= 60 ? Colors.orange : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Classes', totalClasses.toString(), Icons.school, Colors.blue),
              _buildStatCard('Present', presentClasses.toString(), Icons.check_circle, Colors.green),
              _buildStatCard('Absent', absentClasses.toString(), Icons.cancel, Colors.red),
              _buildStatCard('Late', lateClasses.toString(), Icons.schedule, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsTab() {
    final filteredRecords = _filteredRecords;

    return Column(
      children: [
        // Search and sort options
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by course or date...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  // TODO: Implement sort options
                },
                icon: const Icon(Icons.sort),
              ),
            ],
          ),
        ),

        // Records list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredRecords.length,
            itemBuilder: (context, index) {
              final record = filteredRecords[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(record.status),
                    child: Icon(
                      _getStatusIcon(record.status),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(record.courseName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatDate(record.date)),
                      if (record.checkInTime != null)
                        Text('Check-in: ${_formatTime(record.checkInTime!)}'),
                      if (record.reason != null)
                        Text('Reason: ${record.reason}'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(record.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      record.status,
                      style: TextStyle(
                        color: _getStatusColor(record.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekly Trend Chart
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Attendance Trend',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                return Text(days[value.toInt() % 7]);
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}%');
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 85),
                              const FlSpot(1, 90),
                              const FlSpot(2, 88),
                              const FlSpot(3, 92),
                              const FlSpot(4, 87),
                              const FlSpot(5, 95),
                              const FlSpot(6, 89),
                            ],
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Course-wise Statistics
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course-wise Attendance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ...List.generate(_courseStats.length, (index) {
                    final course = _courseStats.keys.elementAt(index);
                    final stats = _courseStats[course]!;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                course,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${stats.attendancePercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: stats.attendancePercentage >= 75 ? Colors.green : 
                                         stats.attendancePercentage >= 60 ? Colors.orange : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: stats.attendancePercentage / 100,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              stats.attendancePercentage >= 75 ? Colors.green : 
                              stats.attendancePercentage >= 60 ? Colors.orange : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stats.presentClasses + stats.lateClasses}/${stats.totalClasses} classes attended',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PRESENT':
        return Colors.green;
      case 'ABSENT':
        return Colors.red;
      case 'LATE':
        return Colors.orange;
      case 'EXCUSED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PRESENT':
        return Icons.check_circle;
      case 'ABSENT':
        return Icons.cancel;
      case 'LATE':
        return Icons.schedule;
      case 'EXCUSED':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'thisWeek':
        return 'This Week';
      case 'thisMonth':
        return 'This Month';
      case 'thisYear':
        return 'This Year';
      case 'all':
        return 'All Time';
      default:
        return period;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Analytics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Records'),
            Tab(text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadAttendanceData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildRecordsTab(),
                _buildAnalyticsTab(),
              ],
            ),
    );
  }
}

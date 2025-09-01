
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(GradingApp());
}

class GradingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Automated Grading App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}

// Data Models
class Student {
  final String id;
  final String name;
  final String email;

  Student({
    required this.name,
    required this.email,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();
}

class Assignment {
  final String id;
  final String title;
  final String description;
  final double maxScore;
  final DateTime dueDate;

  Assignment({
    required this.title,
    required this.description,
    required this.maxScore,
    required this.dueDate,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();
}

class Submission {
  final String id;
  final String studentId;
  final String assignmentId;
  final String content;
  final DateTime submissionDate;
  double? score;
  String? feedback;

  Submission({
    required this.studentId,
    required this.assignmentId,
    required this.content,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       submissionDate = DateTime.now();
}

class GradingResult {
  final double score;
  final String feedback;

  GradingResult(this.score, this.feedback);
}

// Grading Engine
class GradingEngine {
  static final GradingEngine _instance = GradingEngine._internal();
  factory GradingEngine() => _instance;
  GradingEngine._internal();

  final List<String> keywords = [
    'algorithm', 'function', 'variable', 'loop', 'condition',
    'array', 'object', 'class', 'method', 'return'
  ];

  GradingResult gradeSubmission(Submission submission, Assignment assignment) {
    final content = submission.content.toLowerCase();
    final contentLength = submission.content.length;

    // Length score (30% weight)
    final lengthScore = min(contentLength / 500.0, 1.0) * 0.3;

    // Keyword score (40% weight)
    final keywordCount = keywords.where((keyword) => content.contains(keyword)).length;
    final keywordScore = min(keywordCount / 10.0, 1.0) * 0.4;

    // Grammar score (30% weight) - simplified analysis
    final sentences = content.split('.').where((s) => s.trim().isNotEmpty).toList();
    final avgWordsPerSentence = sentences.isNotEmpty 
        ? content.split(' ').length / sentences.length 
        : 0.0;
    final grammarScore = min(avgWordsPerSentence / 15.0, 1.0) * 0.3;

    final totalScore = (lengthScore + keywordScore + grammarScore) * assignment.maxScore;
    final feedback = _generateFeedback(totalScore, assignment.maxScore);

    return GradingResult(totalScore, feedback);
  }

  String _generateFeedback(double score, double maxScore) {
    final percentage = score / maxScore;
    if (percentage >= 0.9) {
      return 'Excellent work! Your submission demonstrates comprehensive understanding.';
    } else if (percentage >= 0.7) {
      return 'Good work! Consider expanding on some concepts for better clarity.';
    } else if (percentage >= 0.5) {
      return 'Fair submission. Please review the assignment requirements and expand your answer.';
    } else {
      return 'Needs improvement. Please provide more detailed explanations and review the material.';
    }
  }
}

// Data Manager
class GradingDataManager extends ChangeNotifier {
  final List<Student> _students = [];
  final List<Assignment> _assignments = [];
  final List<Submission> _submissions = [];

  List<Student> get students => List.unmodifiable(_students);
  List<Assignment> get assignments => List.unmodifiable(_assignments);
  List<Submission> get submissions => List.unmodifiable(_submissions);

  GradingDataManager() {
    _loadSampleData();
  }

  void _loadSampleData() {
    // Sample students
    final alice = Student(name: 'Alice Johnson', email: 'alice@example.com');
    final bob = Student(name: 'Bob Smith', email: 'bob@example.com');
    final carol = Student(name: 'Carol Davis', email: 'carol@example.com');

    _students.addAll([alice, bob, carol]);

    // Sample assignment
    final assignment = Assignment(
      title: 'Algorithm Analysis',
      description: 'Explain the time complexity of quicksort algorithm',
      maxScore: 100.0,
      dueDate: DateTime.now().add(Duration(days: 7)),
    );
    _assignments.add(assignment);

    // Sample submissions
    final submission1 = Submission(
      studentId: alice.id,
      assignmentId: assignment.id,
      content: 'Quicksort is a divide-and-conquer algorithm that works by selecting a pivot element and partitioning the array around it. The average time complexity is O(n log n), but worst case is O(n²).',
    );

    final submission2 = Submission(
      studentId: bob.id,
      assignmentId: assignment.id,
      content: 'Quicksort is fast. It sorts things quickly using recursion and pivot elements.',
    );

    _submissions.addAll([submission1, submission2]);
  }

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void addAssignment(Assignment assignment) {
    _assignments.add(assignment);
    notifyListeners();
  }

  void addSubmission(Submission submission) {
    _submissions.add(submission);
    notifyListeners();
  }

  void gradeSubmission(int index) {
    if (index < _submissions.length) {
      final submission = _submissions[index];
      final assignment = _assignments.firstWhere((a) => a.id == submission.assignmentId);
      
      final result = GradingEngine().gradeSubmission(submission, assignment);
      
      _submissions[index].score = result.score;
      _submissions[index].feedback = result.feedback;
      
      notifyListeners();
    }
  }

  void gradeAllSubmissions() {
    for (int i = 0; i < _submissions.length; i++) {
      gradeSubmission(i);
    }
  }
}

// Main Screen with Bottom Navigation
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late GradingDataManager dataManager;

  @override
  void initState() {
    super.initState();
    dataManager = GradingDataManager();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardView(dataManager: dataManager),
      StudentsView(dataManager: dataManager),
      AssignmentsView(dataManager: dataManager),
      GradingView(dataManager: dataManager),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Assignments'),
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'Grading'),
        ],
      ),
    );
  }
}

// Dashboard View
class DashboardView extends StatelessWidget {
  final GradingDataManager dataManager;

  DashboardView({required this.dataManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: StatCard(title: 'Students', value: '${dataManager.students.length}', color: Colors.blue)),
                SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Assignments', value: '${dataManager.assignments.length}', color: Colors.green)),
                SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Submissions', value: '${dataManager.submissions.length}', color: Colors.orange)),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Activity', style: Theme.of(context).textTheme.headlineSmall),
                      SizedBox(height: 10),
                      Text('• ${dataManager.students.length} students enrolled'),
                      Text('• ${dataManager.assignments.length} assignment created'),
                      Text('• ${dataManager.submissions.length} submissions received'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stat Card Widget
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// Students View
class StudentsView extends StatelessWidget {
  final GradingDataManager dataManager;

  StudentsView({required this.dataManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Students')),
      body: AnimatedBuilder(
        animation: dataManager,
        builder: (context, child) {
          return ListView.builder(
            itemCount: dataManager.students.length,
            itemBuilder: (context, index) {
              final student = dataManager.students[index];
              return ListTile(
                leading: CircleAvatar(child: Text(student.name[0])),
                title: Text(student.name),
                subtitle: Text(student.email),
              );
            },
          );
        },
      ),
    );
  }
}

// Assignments View
class AssignmentsView extends StatelessWidget {
  final GradingDataManager dataManager;

  AssignmentsView({required this.dataManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assignments')),
      body: AnimatedBuilder(
        animation: dataManager,
        builder: (context, child) {
          return ListView.builder(
            itemCount: dataManager.assignments.length,
            itemBuilder: (context, index) {
              final assignment = dataManager.assignments[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignment.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(assignment.description),
                      SizedBox(height: 8),
                      Text('Max Score: ${assignment.maxScore.toInt()}', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Grading View
class GradingView extends StatelessWidget {
  final GradingDataManager dataManager;

  GradingView({required this.dataManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grading'),
        actions: [
          TextButton(
            onPressed: () => dataManager.gradeAllSubmissions(),
            child: Text('Grade All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: dataManager,
        builder: (context, child) {
          return ListView.builder(
            itemCount: dataManager.submissions.length,
            itemBuilder: (context, index) {
              final submission = dataManager.submissions[index];
              final student = dataManager.students.firstWhere((s) => s.id == submission.studentId);
              final assignment = dataManager.assignments.firstWhere((a) => a.id == submission.assignmentId);

              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${student.name} - ${assignment.title}', style: TextStyle(fontWeight: FontWeight.bold)),
                          if (submission.score != null)
                            Text('${submission.score!.toInt()}/${assignment.maxScore.toInt()}', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Submission: ${submission.content}'),
                      if (submission.feedback != null) ...[
                        SizedBox(height: 8),
                        Text('Feedback: ${submission.feedback}', style: TextStyle(color: Colors.green)),
                      ],
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => dataManager.gradeSubmission(index),
                        child: Text('Grade This Submission'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

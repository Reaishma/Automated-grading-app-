
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grading_app/main.dart';

void main() {
  group('GradingApp Widget Tests', () {
    testWidgets('App loads with correct bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(GradingApp());

      // Verify bottom navigation exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify all tabs are present
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Students'), findsOneWidget);
      expect(find.text('Assignments'), findsOneWidget);
      expect(find.text('Grading'), findsOneWidget);
    });

    testWidgets('Dashboard loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(GradingApp());

      // Verify dashboard is shown by default
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Students'), findsNWidgets(2)); // Tab + stat card
      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('Navigation between tabs works', (WidgetTester tester) async {
      await tester.pumpWidget(GradingApp());

      // Tap on Students tab
      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();
      
      // Should show students list
      expect(find.text('Alice Johnson'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);

      // Tap on Assignments tab
      await tester.tap(find.byIcon(Icons.assignment));
      await tester.pumpAndSettle();
      
      // Should show assignments
      expect(find.text('Algorithm Analysis'), findsOneWidget);

      // Tap on Grading tab
      await tester.tap(find.byIcon(Icons.grade));
      await tester.pumpAndSettle();
      
      // Should show grading interface
      expect(find.text('Grade All'), findsOneWidget);
      expect(find.text('Grade This Submission'), findsWidgets);
    });

    testWidgets('Grading functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(GradingApp());

      // Navigate to grading tab
      await tester.tap(find.byIcon(Icons.grade));
      await tester.pumpAndSettle();

      // Tap grade all button
      await tester.tap(find.text('Grade All'));
      await tester.pumpAndSettle();

      // Check that scores appear (should contain "/100")
      expect(find.textContaining('/100'), findsWidgets);
    });
  });

  group('Data Model Tests', () {
    test('Student creation works correctly', () {
      final student = Student(name: 'Test Student', email: 'test@example.com');
      
      expect(student.name, 'Test Student');
      expect(student.email, 'test@example.com');
      expect(student.id, isNotEmpty);
    });

    test('Assignment creation works correctly', () {
      final dueDate = DateTime.now();
      final assignment = Assignment(
        title: 'Test Assignment',
        description: 'Test Description', 
        maxScore: 100.0,
        dueDate: dueDate,
      );
      
      expect(assignment.title, 'Test Assignment');
      expect(assignment.description, 'Test Description');
      expect(assignment.maxScore, 100.0);
      expect(assignment.dueDate, dueDate);
      expect(assignment.id, isNotEmpty);
    });

    test('Grading engine produces valid results', () {
      final gradingEngine = GradingEngine();
      final assignment = Assignment(
        title: 'Test',
        description: 'Test', 
        maxScore: 100.0,
        dueDate: DateTime.now(),
      );
      
      final submission = Submission(
        studentId: 'test',
        assignmentId: assignment.id,
        content: 'This is a comprehensive answer about algorithms and functions.',
      );
      
      final result = gradingEngine.gradeSubmission(submission, assignment);
      
      expect(result.score, greaterThan(0));
      expect(result.score, lessThanOrEqualTo(assignment.maxScore));
      expect(result.feedback, isNotEmpty);
    });
  });
}

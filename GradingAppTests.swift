
import XCTest
@testable import main

class GradingAppTests: XCTestCase {
    var gradingEngine: GradingEngine!
    var dataManager: GradingDataManager!
    
    override func setUpWithError() throws {
        gradingEngine = GradingEngine.shared
        dataManager = GradingDataManager()
    }
    
    override func tearDownWithError() throws {
        gradingEngine = nil
        dataManager = nil
    }
    
    // MARK: - Student Tests
    func testStudentCreation() throws {
        let student = Student(name: "Test Student", email: "test@example.com")
        
        XCTAssertFalse(student.name.isEmpty)
        XCTAssertEqual(student.name, "Test Student")
        XCTAssertEqual(student.email, "test@example.com")
        XCTAssertNotNil(student.id)
    }
    
    func testAddStudent() throws {
        let initialCount = dataManager.students.count
        let newStudent = Student(name: "New Student", email: "new@example.com")
        
        dataManager.addStudent(newStudent)
        
        XCTAssertEqual(dataManager.students.count, initialCount + 1)
        XCTAssertTrue(dataManager.students.contains { $0.id == newStudent.id })
    }
    
    // MARK: - Assignment Tests
    func testAssignmentCreation() throws {
        let dueDate = Date()
        let assignment = Assignment(
            title: "Test Assignment",
            description: "Test Description",
            maxScore: 100.0,
            dueDate: dueDate
        )
        
        XCTAssertEqual(assignment.title, "Test Assignment")
        XCTAssertEqual(assignment.description, "Test Description")
        XCTAssertEqual(assignment.maxScore, 100.0)
        XCTAssertEqual(assignment.dueDate, dueDate)
        XCTAssertNotNil(assignment.id)
    }
    
    func testAddAssignment() throws {
        let initialCount = dataManager.assignments.count
        let newAssignment = Assignment(
            title: "New Assignment",
            description: "New Description",
            maxScore: 50.0,
            dueDate: Date()
        )
        
        dataManager.addAssignment(newAssignment)
        
        XCTAssertEqual(dataManager.assignments.count, initialCount + 1)
        XCTAssertTrue(dataManager.assignments.contains { $0.id == newAssignment.id })
    }
    
    // MARK: - Submission Tests
    func testSubmissionCreation() throws {
        let studentId = UUID()
        let assignmentId = UUID()
        let content = "Test submission content"
        
        let submission = Submission(
            studentId: studentId,
            assignmentId: assignmentId,
            content: content
        )
        
        XCTAssertEqual(submission.studentId, studentId)
        XCTAssertEqual(submission.assignmentId, assignmentId)
        XCTAssertEqual(submission.content, content)
        XCTAssertNotNil(submission.id)
        XCTAssertNil(submission.score)
        XCTAssertNil(submission.feedback)
    }
    
    func testAddSubmission() throws {
        let initialCount = dataManager.submissions.count
        let newSubmission = Submission(
            studentId: UUID(),
            assignmentId: UUID(),
            content: "New submission"
        )
        
        dataManager.addSubmission(newSubmission)
        
        XCTAssertEqual(dataManager.submissions.count, initialCount + 1)
        XCTAssertTrue(dataManager.submissions.contains { $0.id == newSubmission.id })
    }
    
    // MARK: - Grading Engine Tests
    func testGradingEngineBasicFunctionality() throws {
        let assignment = Assignment(
            title: "Test Assignment",
            description: "Test Description",
            maxScore: 100.0,
            dueDate: Date()
        )
        
        let submission = Submission(
            studentId: UUID(),
            assignmentId: assignment.id,
            content: "This is a comprehensive answer about algorithms and functions. It discusses variables, loops, conditions, arrays, objects, classes, methods, and return statements in detail."
        )
        
        let result = gradingEngine.gradeSubmission(submission, assignment: assignment)
        
        XCTAssertGreaterThan(result.score, 0)
        XCTAssertLessThanOrEqual(result.score, assignment.maxScore)
        XCTAssertFalse(result.feedback.isEmpty)
    }
    
    func testGradingEngineWithPoorContent() throws {
        let assignment = Assignment(
            title: "Test Assignment",
            description: "Test Description",
            maxScore: 100.0,
            dueDate: Date()
        )
        
        let submission = Submission(
            studentId: UUID(),
            assignmentId: assignment.id,
            content: "Bad answer."
        )
        
        let result = gradingEngine.gradeSubmission(submission, assignment: assignment)
        
        XCTAssertGreaterThanOrEqual(result.score, 0)
        XCTAssertLessThan(result.score, assignment.maxScore * 0.5) // Should be low score
        XCTAssertTrue(result.feedback.contains("expanding"))
    }
    
    func testGradingEngineWithGoodContent() throws {
        let assignment = Assignment(
            title: "Test Assignment",
            description: "Test Description",
            maxScore: 100.0,
            dueDate: Date()
        )
        
        let submission = Submission(
            studentId: UUID(),
            assignmentId: assignment.id,
            content: """
            This is a comprehensive and well-structured answer about computer science concepts. 
            The algorithm demonstrates efficient use of functions and variables. The implementation 
            includes proper loop structures and conditional statements. Arrays and objects are 
            utilized effectively throughout the class design. Methods return appropriate values 
            and handle edge cases properly. The solution demonstrates strong understanding of 
            fundamental programming concepts and best practices.
            """
        )
        
        let result = gradingEngine.gradeSubmission(submission, assignment: assignment)
        
        XCTAssertGreaterThan(result.score, assignment.maxScore * 0.7) // Should be high score
        XCTAssertTrue(result.feedback.contains("Excellent") || result.feedback.count < 50)
    }
    
    // MARK: - Integration Tests
    func testCompleteGradingWorkflow() throws {
        // Create student and assignment
        let student = Student(name: "Test Student", email: "test@example.com")
        let assignment = Assignment(
            title: "Algorithm Test",
            description: "Explain sorting algorithms",
            maxScore: 100.0,
            dueDate: Date()
        )
        
        dataManager.addStudent(student)
        dataManager.addAssignment(assignment)
        
        // Create submission
        let submission = Submission(
            studentId: student.id,
            assignmentId: assignment.id,
            content: "Bubble sort is a simple algorithm that repeatedly steps through the list, compares adjacent elements and swaps them if they are in the wrong order."
        )
        
        dataManager.addSubmission(submission)
        
        // Grade the submission
        let submissionIndex = dataManager.submissions.count - 1
        dataManager.gradeSubmission(at: submissionIndex)
        
        // Verify grading
        let gradedSubmission = dataManager.submissions[submissionIndex]
        XCTAssertNotNil(gradedSubmission.score)
        XCTAssertNotNil(gradedSubmission.feedback)
        XCTAssertGreaterThan(gradedSubmission.score!, 0)
    }
    
    // MARK: - Performance Tests
    func testGradingPerformance() throws {
        let assignment = Assignment(
            title: "Performance Test",
            description: "Test Description",
            maxScore: 100.0,
            dueDate: Date()
        )
        
        let submission = Submission(
            studentId: UUID(),
            assignmentId: assignment.id,
            content: "This is a test submission for performance testing with algorithms, functions, variables, loops, conditions, arrays, objects, classes, methods, and return statements."
        )
        
        measure {
            _ = gradingEngine.gradeSubmission(submission, assignment: assignment)
        }
    }
    
    func testBulkGradingPerformance() throws {
        // Add multiple submissions
        for i in 0..<10 {
            let submission = Submission(
                studentId: UUID(),
                assignmentId: dataManager.assignments.first?.id ?? UUID(),
                content: "Test submission \(i) with various algorithms and functions."
            )
            dataManager.addSubmission(submission)
        }
        
        measure {
            dataManager.gradeAllSubmissions()
        }
    }
}

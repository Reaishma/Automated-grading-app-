
import org.junit.Test
import org.junit.Assert.*
import org.junit.Before
import java.util.*

class GradingAppTest {
    private lateinit var gradingEngine: GradingEngine
    private lateinit var dataManager: GradingDataManager

    @Before
    fun setUp() {
        gradingEngine = GradingEngine.instance
        dataManager = GradingDataManager()
    }

    @Test
    fun testStudentCreation() {
        val student = Student(name = "Test Student", email = "test@example.com")
        
        assertTrue(student.name.isNotEmpty())
        assertEquals("Test Student", student.name)
        assertEquals("test@example.com", student.email)
        assertNotNull(student.id)
    }

    @Test
    fun testAssignmentCreation() {
        val dueDate = Date()
        val assignment = Assignment(
            title = "Test Assignment",
            description = "Test Description",
            maxScore = 100.0,
            dueDate = dueDate
        )
        
        assertEquals("Test Assignment", assignment.title)
        assertEquals("Test Description", assignment.description)
        assertEquals(100.0, assignment.maxScore, 0.01)
        assertEquals(dueDate, assignment.dueDate)
        assertNotNull(assignment.id)
    }

    @Test
    fun testGradingEngineBasicFunctionality() {
        val assignment = Assignment(
            title = "Test Assignment",
            description = "Test Description",
            maxScore = 100.0,
            dueDate = Date()
        )
        
        val submission = Submission(
            studentId = "test-student",
            assignmentId = assignment.id,
            content = "This is a comprehensive answer about algorithms and functions. It discusses variables, loops, conditions, arrays, objects, classes, methods, and return statements in detail."
        )
        
        val result = gradingEngine.gradeSubmission(submission, assignment)
        
        assertTrue(result.score > 0)
        assertTrue(result.score <= assignment.maxScore)
        assertTrue(result.feedback.isNotEmpty())
    }

    @Test
    fun testGradingEngineWithPoorContent() {
        val assignment = Assignment(
            title = "Test Assignment", 
            description = "Test Description",
            maxScore = 100.0,
            dueDate = Date()
        )
        
        val submission = Submission(
            studentId = "test-student",
            assignmentId = assignment.id,
            content = "Bad answer."
        )
        
        val result = gradingEngine.gradeSubmission(submission, assignment)
        
        assertTrue(result.score >= 0)
        assertTrue(result.score < assignment.maxScore * 0.5)
        assertTrue(result.feedback.contains("improvement", ignoreCase = true))
    }

    @Test
    fun testDataManagerOperations() {
        val initialStudentCount = dataManager.students.size
        val newStudent = Student(name = "New Student", email = "new@example.com")
        
        dataManager.addStudent(newStudent)
        
        assertEquals(initialStudentCount + 1, dataManager.students.size)
        assertTrue(dataManager.students.any { it.id == newStudent.id })
    }

    @Test
    fun testCompleteGradingWorkflow() {
        val student = Student(name = "Test Student", email = "test@example.com")
        val assignment = Assignment(
            title = "Algorithm Test",
            description = "Explain sorting algorithms", 
            maxScore = 100.0,
            dueDate = Date()
        )
        
        dataManager.addStudent(student)
        dataManager.addAssignment(assignment)
        
        val submission = Submission(
            studentId = student.id,
            assignmentId = assignment.id,
            content = "Bubble sort is a simple algorithm that repeatedly steps through the list, compares adjacent elements and swaps them if they are in the wrong order."
        )
        
        dataManager.addSubmission(submission)
        
        val submissionIndex = dataManager.submissions.size - 1
        dataManager.gradeSubmission(submissionIndex)
        
        val gradedSubmission = dataManager.submissions[submissionIndex]
        assertNotNull(gradedSubmission.score)
        assertNotNull(gradedSubmission.feedback)
        assertTrue(gradedSubmission.score!! > 0)
    }
}

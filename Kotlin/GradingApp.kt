
package com.example.gradingapp

import java.util.*
import kotlin.math.min

// Data Models
data class Student(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val email: String
)

data class Assignment(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val description: String,
    val maxScore: Double,
    val dueDate: Date
)

data class Submission(
    val id: String = UUID.randomUUID().toString(),
    val studentId: String,
    val assignmentId: String,
    val content: String,
    val submissionDate: Date = Date(),
    var score: Double? = null,
    var feedback: String? = null
)

// Grading Result
data class GradingResult(
    val score: Double,
    val feedback: String
)

// Grading Engine
class GradingEngine {
    companion object {
        val instance = GradingEngine()
    }
    
    private val keywords = listOf(
        "algorithm", "function", "variable", "loop", "condition", 
        "array", "object", "class", "method", "return"
    )
    
    fun gradeSubmission(submission: Submission, assignment: Assignment): GradingResult {
        val content = submission.content.lowercase()
        val contentLength = submission.content.length
        
        // Length score (30% weight)
        val lengthScore = min(contentLength / 500.0, 1.0) * 0.3
        
        // Keyword score (40% weight)
        val keywordCount = keywords.count { content.contains(it) }
        val keywordScore = min(keywordCount / 10.0, 1.0) * 0.4
        
        // Grammar score (30% weight) - simplified analysis
        val sentences = content.split('.').filter { it.trim().isNotEmpty() }
        val avgWordsPerSentence = if (sentences.isNotEmpty()) {
            content.split(' ').size.toDouble() / sentences.size
        } else 0.0
        val grammarScore = min(avgWordsPerSentence / 15.0, 1.0) * 0.3
        
        val totalScore = (lengthScore + keywordScore + grammarScore) * assignment.maxScore
        
        val feedback = generateFeedback(totalScore, assignment.maxScore)
        
        return GradingResult(totalScore, feedback)
    }
    
    private fun generateFeedback(score: Double, maxScore: Double): String {
        val percentage = score / maxScore
        return when {
            percentage >= 0.9 -> "Excellent work! Your submission demonstrates comprehensive understanding."
            percentage >= 0.7 -> "Good work! Consider expanding on some concepts for better clarity."
            percentage >= 0.5 -> "Fair submission. Please review the assignment requirements and expand your answer."
            else -> "Needs improvement. Please provide more detailed explanations and review the material."
        }
    }
}

// Data Manager
class GradingDataManager {
    private val _students = mutableListOf<Student>()
    private val _assignments = mutableListOf<Assignment>()
    private val _submissions = mutableListOf<Submission>()
    
    val students: List<Student> get() = _students.toList()
    val assignments: List<Assignment> get() = _assignments.toList()
    val submissions: List<Submission> get() = _submissions.toList()
    
    init {
        loadSampleData()
    }
    
    private fun loadSampleData() {
        // Sample students
        val alice = Student(name = "Alice Johnson", email = "alice@example.com")
        val bob = Student(name = "Bob Smith", email = "bob@example.com")
        val carol = Student(name = "Carol Davis", email = "carol@example.com")
        
        _students.addAll(listOf(alice, bob, carol))
        
        // Sample assignment
        val assignment = Assignment(
            title = "Algorithm Analysis",
            description = "Explain the time complexity of quicksort algorithm",
            maxScore = 100.0,
            dueDate = Date()
        )
        _assignments.add(assignment)
        
        // Sample submissions
        val submission1 = Submission(
            studentId = alice.id,
            assignmentId = assignment.id,
            content = "Quicksort is a divide-and-conquer algorithm that works by selecting a pivot element and partitioning the array around it. The average time complexity is O(n log n), but worst case is O(n²)."
        )
        
        val submission2 = Submission(
            studentId = bob.id,
            assignmentId = assignment.id,
            content = "Quicksort is fast. It sorts things quickly using recursion and pivot elements."
        )
        
        _submissions.addAll(listOf(submission1, submission2))
    }
    
    fun addStudent(student: Student) {
        _students.add(student)
    }
    
    fun addAssignment(assignment: Assignment) {
        _assignments.add(assignment)
    }
    
    fun addSubmission(submission: Submission) {
        _submissions.add(submission)
    }
    
    fun gradeSubmission(index: Int) {
        if (index < _submissions.size) {
            val submission = _submissions[index]
            val assignment = _assignments.find { it.id == submission.assignmentId }
            
            assignment?.let {
                val result = GradingEngine.instance.gradeSubmission(submission, it)
                _submissions[index] = submission.copy(
                    score = result.score,
                    feedback = result.feedback
                )
            }
        }
    }
    
    fun gradeAllSubmissions() {
        for (i in _submissions.indices) {
            gradeSubmission(i)
        }
    }
}

// Console Application for Testing
fun main() {
    println("=== Automated Grading App (Kotlin) ===")
    
    val dataManager = GradingDataManager()
    
    println("\nStudents:")
    dataManager.students.forEach { student ->
        println("- ${student.name} (${student.email})")
    }
    
    println("\nAssignments:")
    dataManager.assignments.forEach { assignment ->
        println("- ${assignment.title}: ${assignment.description}")
        println("  Max Score: ${assignment.maxScore}")
    }
    
    println("\nSubmissions before grading:")
    dataManager.submissions.forEach { submission ->
        val student = dataManager.students.find { it.id == submission.studentId }
        val assignment = dataManager.assignments.find { it.id == submission.assignmentId }
        println("- ${student?.name} - ${assignment?.title}")
        println("  Content: ${submission.content}")
        println("  Score: ${submission.score ?: "Not graded"}")
    }
    
    println("\nGrading all submissions...")
    dataManager.gradeAllSubmissions()
    
    println("\nSubmissions after grading:")
    dataManager.submissions.forEach { submission ->
        val student = dataManager.students.find { it.id == submission.studentId }
        val assignment = dataManager.assignments.find { it.id == submission.assignmentId }
        println("- ${student?.name} - ${assignment?.title}")
        println("  Score: ${submission.score?.toInt()}/${assignment?.maxScore?.toInt()}")
        println("  Feedback: ${submission.feedback}")
        println()
    }
}

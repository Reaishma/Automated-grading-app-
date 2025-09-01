
import Foundation
import SwiftUI

// MARK: - Core Data Models
struct Student {
    let id: UUID
    let name: String
    let email: String
    
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
    }
}

struct Assignment {
    let id: UUID
    let title: String
    let description: String
    let maxScore: Double
    let dueDate: Date
    
    init(title: String, description: String, maxScore: Double, dueDate: Date) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.maxScore = maxScore
        self.dueDate = dueDate
    }
}

struct Submission {
    let id: UUID
    let studentId: UUID
    let assignmentId: UUID
    let content: String
    let submissionDate: Date
    var score: Double?
    var feedback: String?
    
    init(studentId: UUID, assignmentId: UUID, content: String) {
        self.id = UUID()
        self.studentId = studentId
        self.assignmentId = assignmentId
        self.content = content
        self.submissionDate = Date()
    }
}

// MARK: - Core ML Grading Engine
class GradingEngine {
    static let shared = GradingEngine()
    
    private init() {}
    
    func gradeSubmission(_ submission: Submission, assignment: Assignment) -> (score: Double, feedback: String) {
        // Simulate ML-based grading
        let contentLength = submission.content.count
        let keywordCount = countKeywords(in: submission.content)
        let grammarScore = analyzeGrammar(submission.content)
        
        // Simple scoring algorithm (in real app, this would use Core ML model)
        let lengthScore = min(Double(contentLength) / 500.0, 1.0) * 0.3
        let keywordScore = min(Double(keywordCount) / 10.0, 1.0) * 0.4
        let grammarScoreNormalized = grammarScore * 0.3
        
        let totalScore = (lengthScore + keywordScore + grammarScoreNormalized) * assignment.maxScore
        
        let feedback = generateFeedback(lengthScore: lengthScore, keywordScore: keywordScore, grammarScore: grammarScore)
        
        return (score: totalScore, feedback: feedback)
    }
    
    private func countKeywords(in text: String) -> Int {
        let keywords = ["algorithm", "function", "variable", "loop", "condition", "array", "object", "class", "method", "return"]
        let lowercaseText = text.lowercased()
        return keywords.reduce(0) { count, keyword in
            count + (lowercaseText.contains(keyword) ? 1 : 0)
        }
    }
    
    private func analyzeGrammar(_ text: String) -> Double {
        // Simplified grammar analysis
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        
        guard !sentences.isEmpty && !words.isEmpty else { return 0.0 }
        
        let averageWordsPerSentence = Double(words.count) / Double(sentences.count)
        let idealWordsPerSentence = 15.0
        
        return max(0.0, 1.0 - abs(averageWordsPerSentence - idealWordsPerSentence) / idealWordsPerSentence)
    }
    
    private func generateFeedback(lengthScore: Double, keywordScore: Double, grammarScore: Double) -> String {
        var feedback = "Grading Results:\n"
        
        if lengthScore < 0.5 {
            feedback += "• Consider expanding your answer with more details.\n"
        }
        
        if keywordScore < 0.5 {
            feedback += "• Try to include more relevant technical terms.\n"
        }
        
        if grammarScore < 0.7 {
            feedback += "• Review sentence structure and grammar.\n"
        }
        
        if lengthScore > 0.8 && keywordScore > 0.8 && grammarScore > 0.8 {
            feedback += "• Excellent work! Well-structured and comprehensive answer.\n"
        }
        
        return feedback
    }
}

// MARK: - Data Manager
class GradingDataManager: ObservableObject {
    @Published var students: [Student] = []
    @Published var assignments: [Assignment] = []
    @Published var submissions: [Submission] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample students
        students = [
            Student(name: "Alice Johnson", email: "alice@example.com"),
            Student(name: "Bob Smith", email: "bob@example.com"),
            Student(name: "Carol Davis", email: "carol@example.com")
        ]
        
        // Sample assignment
        let assignment = Assignment(
            title: "Algorithm Analysis",
            description: "Explain the time complexity of quicksort algorithm",
            maxScore: 100.0,
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        )
        assignments = [assignment]
        
        // Sample submissions
        submissions = [
            Submission(
                studentId: students[0].id,
                assignmentId: assignment.id,
                content: "Quicksort is a divide-and-conquer algorithm. It has an average time complexity of O(n log n) and worst-case complexity of O(n²). The algorithm works by selecting a pivot element and partitioning the array around it."
            ),
            Submission(
                studentId: students[1].id,
                assignmentId: assignment.id,
                content: "Quicksort is fast. It sorts things quickly using recursion and pivot elements."
            )
        ]
    }
    
    func addStudent(_ student: Student) {
        students.append(student)
    }
    
    func addAssignment(_ assignment: Assignment) {
        assignments.append(assignment)
    }
    
    func addSubmission(_ submission: Submission) {
        submissions.append(submission)
    }
    
    func gradeSubmission(at index: Int) {
        guard index < submissions.count else { return }
        
        let submission = submissions[index]
        guard let assignment = assignments.first(where: { $0.id == submission.assignmentId }) else { return }
        
        let result = GradingEngine.shared.gradeSubmission(submission, assignment: assignment)
        
        submissions[index] = Submission(
            studentId: submission.studentId,
            assignmentId: submission.assignmentId,
            content: submission.content
        )
        submissions[index].score = result.score
        submissions[index].feedback = result.feedback
    }
    
    func gradeAllSubmissions() {
        for i in 0..<submissions.count {
            gradeSubmission(at: i)
        }
    }
}

// MARK: - SwiftUI Views
struct ContentView: View {
    @StateObject private var dataManager = GradingDataManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            StudentsView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Students")
                }
                .tag(1)
            
            AssignmentsView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Assignments")
                }
                .tag(2)
            
            GradingView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Grading")
                }
                .tag(3)
        }
    }
}

struct DashboardView: View {
    @ObservedObject var dataManager: GradingDataManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    StatCard(title: "Students", value: "\(dataManager.students.count)", color: .blue)
                    StatCard(title: "Assignments", value: "\(dataManager.assignments.count)", color: .green)
                    StatCard(title: "Submissions", value: "\(dataManager.submissions.count)", color: .orange)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Activity")
                        .font(.headline)
                    
                    ForEach(dataManager.submissions.prefix(3), id: \.id) { submission in
                        if let student = dataManager.students.first(where: { $0.id == submission.studentId }),
                           let assignment = dataManager.assignments.first(where: { $0.id == submission.assignmentId }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(student.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Submitted: \(assignment.title)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if let score = submission.score {
                                    Text("\(Int(score))/\(Int(assignment.maxScore))")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(8)
                                } else {
                                    Text("Pending")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.yellow.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct StudentsView: View {
    @ObservedObject var dataManager: GradingDataManager
    
    var body: some View {
        NavigationView {
            List(dataManager.students, id: \.id) { student in
                VStack(alignment: .leading) {
                    Text(student.name)
                        .font(.headline)
                    Text(student.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Students")
        }
    }
}

struct AssignmentsView: View {
    @ObservedObject var dataManager: GradingDataManager
    
    var body: some View {
        NavigationView {
            List(dataManager.assignments, id: \.id) { assignment in
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.title)
                        .font(.headline)
                    Text(assignment.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Text("Max Score: \(Int(assignment.maxScore))")
                        Spacer()
                        Text("Due: \(assignment.dueDate, formatter: dateFormatter)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Assignments")
        }
    }
}

struct GradingView: View {
    @ObservedObject var dataManager: GradingDataManager
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("Grade All Submissions") {
                        dataManager.gradeAllSubmissions()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
                
                List(dataManager.submissions.indices, id: \.self) { index in
                    let submission = dataManager.submissions[index]
                    if let student = dataManager.students.first(where: { $0.id == submission.studentId }),
                       let assignment = dataManager.assignments.first(where: { $0.id == submission.assignmentId }) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(student.name) - \(assignment.title)")
                                    .font(.headline)
                                Spacer()
                                if let score = submission.score {
                                    Text("\(Int(score))/\(Int(assignment.maxScore))")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Text("Submission:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(submission.content)
                                .font(.caption)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                            
                            if let feedback = submission.feedback {
                                Text("Feedback:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(feedback)
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            Button("Grade This Submission") {
                                dataManager.gradeSubmission(at: index)
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                }
            }
            .navigationTitle("Grading")
        }
    }
}

// MARK: - Helper Extensions
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

// MARK: - App Entry Point
@main
struct GradingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

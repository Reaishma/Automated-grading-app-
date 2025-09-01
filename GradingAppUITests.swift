
import XCTest

class GradingAppUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Dashboard Tests
    func testDashboardLoadsCorrectly() throws {
        // Test dashboard tab is selected by default
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.exists)
        XCTAssertTrue(dashboardTab.isSelected)
        
        // Check for dashboard elements
        XCTAssertTrue(app.navigationBars["Dashboard"].exists)
        XCTAssertTrue(app.staticTexts["Students"].exists)
        XCTAssertTrue(app.staticTexts["Assignments"].exists)
        XCTAssertTrue(app.staticTexts["Submissions"].exists)
    }
    
    func testDashboardStatCards() throws {
        // Verify stat cards display numbers
        let studentsCard = app.staticTexts["Students"]
        let assignmentsCard = app.staticTexts["Assignments"] 
        let submissionsCard = app.staticTexts["Submissions"]
        
        XCTAssertTrue(studentsCard.exists)
        XCTAssertTrue(assignmentsCard.exists)
        XCTAssertTrue(submissionsCard.exists)
        
        // Check that numbers are displayed (should be > 0 from sample data)
        let numberRegex = try NSRegularExpression(pattern: "\\d+")
        
        // These should contain numeric values from the sample data
        XCTAssertTrue(app.staticTexts.matching(identifier: "3").firstMatch.exists) // 3 students
        XCTAssertTrue(app.staticTexts.matching(identifier: "1").firstMatch.exists) // 1 assignment
        XCTAssertTrue(app.staticTexts.matching(identifier: "2").firstMatch.exists) // 2 submissions
    }
    
    // MARK: - Navigation Tests
    func testTabNavigation() throws {
        // Test Students tab
        let studentsTab = app.tabBars.buttons["Students"]
        studentsTab.tap()
        XCTAssertTrue(app.navigationBars["Students"].exists)
        
        // Test Assignments tab
        let assignmentsTab = app.tabBars.buttons["Assignments"]
        assignmentsTab.tap()
        XCTAssertTrue(app.navigationBars["Assignments"].exists)
        
        // Test Grading tab
        let gradingTab = app.tabBars.buttons["Grading"]
        gradingTab.tap()
        XCTAssertTrue(app.navigationBars["Grading"].exists)
        
        // Return to Dashboard
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        dashboardTab.tap()
        XCTAssertTrue(app.navigationBars["Dashboard"].exists)
    }
    
    // MARK: - Students View Tests
    func testStudentsViewDisplaysStudents() throws {
        app.tabBars.buttons["Students"].tap()
        
        // Check for sample students
        XCTAssertTrue(app.staticTexts["Alice Johnson"].exists)
        XCTAssertTrue(app.staticTexts["alice@example.com"].exists)
        XCTAssertTrue(app.staticTexts["Bob Smith"].exists)
        XCTAssertTrue(app.staticTexts["bob@example.com"].exists)
        XCTAssertTrue(app.staticTexts["Carol Davis"].exists)
        XCTAssertTrue(app.staticTexts["carol@example.com"].exists)
    }
    
    // MARK: - Assignments View Tests
    func testAssignmentsViewDisplaysAssignments() throws {
        app.tabBars.buttons["Assignments"].tap()
        
        // Check for sample assignment
        XCTAssertTrue(app.staticTexts["Algorithm Analysis"].exists)
        XCTAssertTrue(app.staticTexts["Explain the time complexity of quicksort algorithm"].exists)
        XCTAssertTrue(app.staticTexts["Max Score: 100"].exists)
    }
    
    // MARK: - Grading View Tests
    func testGradingViewDisplaysSubmissions() throws {
        app.tabBars.buttons["Grading"].tap()
        
        // Check for grade all button
        let gradeAllButton = app.buttons["Grade All Submissions"]
        XCTAssertTrue(gradeAllButton.exists)
        XCTAssertTrue(gradeAllButton.isEnabled)
        
        // Check for individual submissions
        XCTAssertTrue(app.staticTexts["Alice Johnson - Algorithm Analysis"].exists)
        XCTAssertTrue(app.staticTexts["Bob Smith - Algorithm Analysis"].exists)
        
        // Check for submission content
        XCTAssertTrue(app.staticTexts["Submission:"].exists)
        XCTAssertTrue(app.staticTexts.containing("Quicksort is a divide-and-conquer").firstMatch.exists)
    }
    
    func testIndividualGradingButton() throws {
        app.tabBars.buttons["Grading"].tap()
        
        let gradeButton = app.buttons["Grade This Submission"].firstMatch
        XCTAssertTrue(gradeButton.exists)
        XCTAssertTrue(gradeButton.isEnabled)
        
        // Tap the button
        gradeButton.tap()
        
        // Check that feedback appears after grading
        let expectation = XCTestExpectation(description: "Feedback appears")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.app.staticTexts["Feedback:"].exists {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testGradeAllSubmissionsButton() throws {
        app.tabBars.buttons["Grading"].tap()
        
        let gradeAllButton = app.buttons["Grade All Submissions"]
        gradeAllButton.tap()
        
        // Wait for grading to complete
        let expectation = XCTestExpectation(description: "All submissions graded")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Check that scores appear
            if self.app.staticTexts.matching(NSPredicate(format: "label CONTAINS '/100'")).count > 0 {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Accessibility Tests
    func testAccessibilityElements() throws {
        // Test that key elements have accessibility labels
        app.tabBars.buttons["Dashboard"].tap()
        
        let dashboardTitle = app.navigationBars["Dashboard"]
        XCTAssertTrue(dashboardTitle.exists)
        
        // Test tab accessibility
        let tabs = app.tabBars.buttons
        XCTAssertEqual(tabs.count, 4)
        
        for i in 0..<tabs.count {
            let tab = tabs.element(boundBy: i)
            XCTAssertTrue(tab.isHittable)
        }
    }
    
    // MARK: - Performance Tests
    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testScrollPerformance() throws {
        app.tabBars.buttons["Grading"].tap()
        
        let scrollView = app.scrollViews.firstMatch
        
        measure {
            scrollView.swipeUp()
            scrollView.swipeDown()
        }
    }
    
    // MARK: - Error Handling Tests
    func testUIRespondsToDataChanges() throws {
        app.tabBars.buttons["Dashboard"].tap()
        
        // Verify initial state
        let studentsCount = app.staticTexts["3"]
        XCTAssertTrue(studentsCount.exists)
        
        // Navigate to other tabs and back to ensure UI updates
        app.tabBars.buttons["Students"].tap()
        app.tabBars.buttons["Dashboard"].tap()
        
        // Verify state is maintained
        XCTAssertTrue(app.staticTexts["3"].exists)
    }
    
    func testGradingViewUpdatesAfterGrading() throws {
        app.tabBars.buttons["Grading"].tap()
        
        // Check initial state (no scores)
        let initialScoreElements = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '/100'"))
        let initialScoreCount = initialScoreElements.count
        
        // Perform grading
        let gradeAllButton = app.buttons["Grade All Submissions"]
        gradeAllButton.tap()
        
        // Wait and check for score updates
        let expectation = XCTestExpectation(description: "Scores updated in UI")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let updatedScoreElements = self.app.staticTexts.matching(NSPredicate(format: "label CONTAINS '/100'"))
            if updatedScoreElements.count > initialScoreCount {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
}

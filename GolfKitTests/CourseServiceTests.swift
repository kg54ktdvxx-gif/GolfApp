import XCTest
import SwiftData
@testable import GolfKit

@MainActor
final class CourseServiceTests: XCTestCase {
    var sut: CourseService!
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    
    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: GolfCourse.self, Hole.self, Round.self,
            configurations: config
        )
        modelContext = ModelContext(modelContainer)
        sut = CourseService(modelContext: modelContext)
    }
    
    override func tearDown() async throws {
        sut = nil
        modelContext = nil
        modelContainer = nil
    }
    
    func testGetAllCourses_WhenEmpty_ReturnsEmptyArray() throws {
        // When
        let courses = try sut.getAllCourses()
        
        // Then
        XCTAssertTrue(courses.isEmpty)
    }
    
    func testGetAllCourses_WithCourses_ReturnsAllCourses() throws {
        // Given
        let course1 = GolfCourse(name: "Course 1", lat: 0, lon: 0)
        let course2 = GolfCourse(name: "Course 2", lat: 1, lon: 1)
        modelContext.insert(course1)
        modelContext.insert(course2)
        try modelContext.save()
        
        // When
        let courses = try sut.getAllCourses()
        
        // Then
        XCTAssertEqual(courses.count, 2)
    }
    
    func testSearchCourses_WithMatchingQuery_ReturnsMatchingCourses() async throws {
        // Given
        let course1 = GolfCourse(name: "Pebble Beach", lat: 0, lon: 0)
        let course2 = GolfCourse(name: "Augusta National", lat: 1, lon: 1)
        modelContext.insert(course1)
        modelContext.insert(course2)
        try modelContext.save()
        
        // When
        let results = try await sut.searchCourses(query: "Pebble")
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Pebble Beach")
    }
    
    func testSearchCourses_WithEmptyQuery_ReturnsMockCourse() async throws {
        // When
        let results = try await sut.searchCourses(query: "")
        
        // Then
        XCTAssertFalse(results.isEmpty)
    }
    
    func testGetCourse_WithValidId_ReturnsCourse() throws {
        // Given
        let course = GolfCourse(name: "Test Course", lat: 0, lon: 0)
        modelContext.insert(course)
        try modelContext.save()
        
        // When
        let result = try sut.getCourse(id: course.id)
        
        // Then
        XCTAssertEqual(result.id, course.id)
        XCTAssertEqual(result.name, "Test Course")
    }
    
    func testGetCourse_WithInvalidId_ThrowsError() {
        // When/Then
        XCTAssertThrowsError(try sut.getCourse(id: "invalid-id")) { error in
            XCTAssertTrue(error is CourseService.CourseError)
        }
    }
}

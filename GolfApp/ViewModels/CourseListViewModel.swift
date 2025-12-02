import Foundation
import SwiftData

/// View model for managing course search and browsing.
@MainActor
final class CourseListViewModel: ObservableObject {
    @Published var courses: [GolfCourse] = []
    @Published var filteredCourses: [GolfCourse] = []
    @Published var searchText: String = "" {
        didSet {
            filterCourses()
        }
    }
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let courseService: CourseService
    
    init(modelContext: ModelContext) {
        self.courseService = CourseService(modelContext: modelContext)
    }
    
    // MARK: - Public Methods
    
    /// Load all courses from bundle
    func loadCourses() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            courses = try courseService.getAllCourses()
            filteredCourses = courses
            error = nil
        } catch let error as CourseServiceError {
            self.error = error.errorDescription
        } catch {
            self.error = "Unknown error: \(error.localizedDescription)"
        }
    }
    
    /// Search courses by query
    func searchCourses(query: String) {
        isLoading = true
        defer { isLoading = false }
        
        Task {
            do {
                let results = try await courseService.searchCourses(query: query)
                self.filteredCourses = results
                self.error = nil
            } catch let error as CourseServiceError {
                self.error = error.errorDescription
            } catch {
                self.error = "Search failed: \(error.localizedDescription)"
            }
        }
    }
    
    /// Get course by ID
    func getCourse(id: String) -> GolfCourse? {
        do {
            return try courseService.getCourse(id: id)
        } catch {
            self.error = "Course not found"
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func filterCourses() {
        if searchText.isEmpty {
            filteredCourses = courses
        } else {
            filteredCourses = courses.filter { course in
                course.name.localizedCaseInsensitiveContains(searchText) ||
                course.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

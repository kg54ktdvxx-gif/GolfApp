import Foundation
import SwiftData

@MainActor
public final class CourseService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public enum CourseError: Error, LocalizedError {
        case notFound
        case decodingError
        
        public var errorDescription: String? {
            switch self {
            case .notFound: return "Course not found"
            case .decodingError: return "Failed to decode course data"
            }
        }
    }
    
    public func getAllCourses() throws -> [GolfCourse] {
        let descriptor = FetchDescriptor<GolfCourse>()
        return try modelContext.fetch(descriptor)
    }
    
    public func searchCourses(query: String) async throws -> [GolfCourse] {
        // In a real app, this might search an API or a local JSON file.
        // For now, we'll return a mock course if the query matches or is empty.
        
        let descriptor = FetchDescriptor<GolfCourse>(
            predicate: #Predicate { $0.name.contains(query) }
        )
        
        let localCourses = try modelContext.fetch(descriptor)
        
        if !localCourses.isEmpty {
            return localCourses
        }
        
        // If no local courses, maybe load some defaults (mocking for now)
        if query.isEmpty || "Augusta National".contains(query) {
            return [MockData.augusta]
        }
        
        return []
    }
    
    public func getCourse(id: String) throws -> GolfCourse {
        let descriptor = FetchDescriptor<GolfCourse>(
            predicate: #Predicate { $0.id == id }
        )
        
        guard let course = try modelContext.fetch(descriptor).first else {
            throw CourseError.notFound
        }
        
        return course
    }
}

// Mock Data for testing/previews
public struct MockData {
    public static let augusta = GolfCourse(
        name: "Augusta National",
        lat: 33.5021,
        lon: -82.0226,
        location: "2604 Washington Rd, Augusta, GA 30904",
        holes: (1...18).map { i in
            Hole(number: i, par: 4, handicap: i, distance: 400)
        }
    )
}

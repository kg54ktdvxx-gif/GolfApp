import SwiftUI
import SwiftData
import GolfKit

@main
struct GolfAppApp: App {
    let modelContainer: ModelContainer
    let courseService: CourseService
    let locationService: LocationService
    let statsService: StatsService
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environment(courseService)
                .environment(locationService)
                .environment(statsService)
        }
    }
    
    init() {
        do {
            let config = ModelConfiguration(
                schema: Schema([
                    GolfCourse.self,
                    Hole.self,
                    Round.self,
                    Club.self,
                    Shot.self,
                ]),
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(for: GolfCourse.self, configurations: config)
            
            // Initialize services with proper dependency injection
            let modelContext = ModelContext(modelContainer)
            self.courseService = CourseService(modelContext: modelContext)
            self.locationService = LocationService()
            self.statsService = StatsService()
        } catch {
            fatalError("Could not initialize app: \(error)")
        }
    }
}

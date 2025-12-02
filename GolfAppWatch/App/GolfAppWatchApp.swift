import SwiftUI
import SwiftData

@main
struct GolfAppWatchApp: App {
    let modelContainer: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
    
    init() {
        do {
            let config = ModelConfiguration(
                schema: Schema([
                    GolfCourse.self,
                    Hole.self,
                    Round.self,
                ]),
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(for: GolfCourse.self, configurations: config)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
}

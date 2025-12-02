import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .courses
    @Environment(\.modelContext) var modelContext
    
    enum Tab {
        case courses
        case stats
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CourseSearchView()
                .tabItem {
                    Label("Courses", systemImage: "map")
                }
                .tag(Tab.courses)
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(Tab.stats)
        }
    }
}

#Preview {
    ContentView()
}

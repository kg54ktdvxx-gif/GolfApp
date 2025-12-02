import SwiftUI
import SwiftData

struct WatchRoundScoringView: View {
    @State private var activeRound: Round?
    @State private var currentHole: Int = 1
    @State private var gpsDistance: Int = 0
    @State private var showCourseSelection = false
    @State private var courses: [GolfCourse] = []
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        if let round = activeRound {
            // Active round view
            VStack(spacing: 8) {
                // Hole number
                Text("Hole \(currentHole)")
                    .font(.title3)
                    .bold()
                
                // GPS distance
                VStack(spacing: 2) {
                    Text("\(gpsDistance)m")
                        .font(.headline)
                    Text("to green")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                // Score buttons (compact)
                HStack(spacing: 4) {
                    ForEach(3...6, id: \.self) { score in
                        Button(String(score)) {
                            recordScore(score)
                        }
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    }
                }
                
                HStack(spacing: 4) {
                    ForEach(7...9, id: \.self) { score in
                        Button(String(score)) {
                            recordScore(score)
                        }
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    }
                }
                
                // Finish button
                if currentHole > 18 {
                    Button("Finish") {
                        finishRound()
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(4)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                }
            }
            .padding(8)
        } else {
            // No active round - show start button
            VStack(spacing: 12) {
                Image(systemImage: "golf.circle")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                
                Text("Start Round")
                    .font(.headline)
                
                Button("New Round") {
                    showCourseSelection = true
                }
                .buttonStyle(.borderedProminent)
            }
            .sheet(isPresented: $showCourseSelection) {
                WatchCourseSelectionView(isPresented: $showCourseSelection) { course in
                    startRound(course: course)
                }
            }
        }
    }
    
    private func recordScore(_ score: Int) {
        guard var round = activeRound else { return }
        guard currentHole <= 18 else { return }
        
        round.scores[currentHole - 1] = score
        activeRound = round
        
        if currentHole < 18 {
            currentHole += 1
        }
    }
    
    private func startRound(course: GolfCourse) {
        let newRound = Round(
            id: UUID().uuidString,
            courseId: course.id,
            date: Date(),
            scores: Array(repeating: 0, count: 18)
        )
        activeRound = newRound
        currentHole = 1
        showCourseSelection = false
    }
    
    private func finishRound() {
        guard let round = activeRound else { return }
        modelContext.insert(round)
        try? modelContext.save()
        activeRound = nil
        currentHole = 1
    }
}

struct WatchCourseSelectionView: View {
    @Binding var isPresented: Bool
    let onSelect: (GolfCourse) -> Void
    
    @State private var courses: [GolfCourse] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Select Course")
                .font(.headline)
            
            if isLoading {
                ProgressView()
            } else if courses.isEmpty {
                Text("No courses")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                List(courses) { course in
                    Button(action: {
                        onSelect(course)
                        isPresented = false
                    }) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(course.name)
                                .font(.caption)
                                .bold()
                            Text("Par \(course.par)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            Button("Cancel") {
                isPresented = false
            }
            .buttonStyle(.bordered)
        }
        .padding(8)
        .onAppear {
            loadCourses()
        }
    }
    
    private func loadCourses() {
        isLoading = true
        Task {
            do {
                let container = try ModelContainer(for: GolfCourse.self)
                let context = ModelContext(container)
                let service = CourseService(modelContext: context)
                courses = try service.getAllCourses()
            } catch {
                print("Error loading courses: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
}

#Preview {
    WatchRoundScoringView()
}

import SwiftUI
import SwiftData
import GolfKit

struct RoundScoringView: View {
    let course: GolfCourse
    @StateObject private var vm: RoundViewModel
    @Environment(\.modelContext) var modelContext
    @Environment(LocationService.self) var locationService
    @Environment(\.dismiss) var dismiss
    @State private var showFinishAlert = false
    @State private var error: Error?
    
    init(course: GolfCourse, modelContext: ModelContext, locationService: LocationService) {
        self.course = course
        _vm = StateObject(wrappedValue: RoundViewModel(
            course: course,
            modelContext: modelContext,
            locationService: locationService
        ))
    }
    
    var currentHole: Hole? {
        guard vm.currentHole <= course.holes.count else { return nil }
        return course.holes[vm.currentHole - 1]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(course.name)
                        .font(.headline)
                    Text("Hole \(vm.currentHole) of 18")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    if vm.isLoadingLocation {
                        ProgressView()
                            .frame(width: 20, height: 20)
                    } else {
                        Text("\(vm.gpsDistance)m")
                            .font(.title3)
                            .bold()
                    }
                    Text("to green")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Current hole info
            if let hole = currentHole {
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Par")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(hole.par)")
                            .font(.title2)
                            .bold()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Handicap")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(hole.handicap)")
                            .font(.title2)
                            .bold()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Yardage")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(hole.averageYardage)")
                            .font(.title2)
                            .bold()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
            // Score buttons
            VStack(spacing: 8) {
                Text("Record Score")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 8) {
                    ForEach(2...5, id: \.self) { score in
                        ScoreButton(score: score) {
                            vm.recordScore(score)
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    ForEach(6...9, id: \.self) { score in
                        ScoreButton(score: score) {
                            vm.recordScore(score)
                        }
                    }
                }
            }
            .padding()
            
            // Error message
            if let error = vm.error {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.orange)
                    Text(error.errorDescription ?? "Location error")
                        .font(.caption)
                }
                .padding()
                .background(Color(.systemOrange).opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                if vm.currentHole > 1 {
                    Button(action: { vm.undoScore() }) {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                if vm.currentHole > 18 {
                    Button(action: { showFinishAlert = true }) {
                        Text("Finish Round")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .padding()
        }
        .padding()
        .navigationTitle("Scoring")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.startRound()
        }
        .alert("Finish Round?", isPresented: $showFinishAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Finish", role: .destructive) {
                finishRound()
            }
        } message: {
            Text("Save this round?")
        }
    }
    
    private func finishRound() {
        do {
            try vm.finishRound()
            dismiss()
        } catch {
            self.error = error
        }
    }
}

struct ScoreButton: View {
    let score: Int
    let action: () -> Void
    
    var body: some View {
        Button(String(score), action: action)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    let mockCourse = GolfCourse(
        id: "test-1",
        name: "Pebble Beach",
        location: "Pebble Beach, CA",
        lat: 36.5627,
        lon: -121.9496,
        par: 72,
        handicap: 2,
        holes: []
    )
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Round.self, configurations: config)
    let modelContext = ModelContext(container)
    let locationService = LocationService()
    
    RoundScoringView(
        course: mockCourse,
        modelContext: modelContext,
        locationService: locationService
    )
}

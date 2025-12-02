import SwiftUI
import SwiftData

struct RoundScoringView: View {
    let course: GolfCourse
    @StateObject private var vm: RoundViewModel
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    init(course: GolfCourse) {
        self.course = course
        let container = try! ModelContainer(for: Round.self)
        let context = ModelContext(container)
        _vm = StateObject(wrappedValue: RoundViewModel(course: course, modelContext: context))
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
                    Text("\(vm.gpsDistance)m")
                        .font(.title3)
                        .bold()
                    Text("to green")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Current hole info
            if let hole = vm.currentHoleInfo {
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
                    
                    Spacer()
                }
                .padding()
            }
            
            // Error message
            if let error = vm.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color(.systemRed).opacity(0.1))
                    .cornerRadius(4)
            }
            
            // Score buttons
            VStack(spacing: 8) {
                Text("Record Score")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 8) {
                    ForEach(2...5, id: \.self) { score in
                        Button(String(score)) {
                            vm.recordScore(score)
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }
                
                HStack(spacing: 8) {
                    ForEach(6...9, id: \.self) { score in
                        Button(String(score)) {
                            vm.recordScore(score)
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { vm.undoLastScore() }) {
                    Label("Undo", systemImage: "arrow.uturn.left")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                
                if vm.currentHole > 18 {
                    Button(action: finishRound) {
                        Text("Finish Round")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(vm.isLoading)
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
    }
    
    private func finishRound() {
        vm.finishRound()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
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
    RoundScoringView(course: mockCourse)
}

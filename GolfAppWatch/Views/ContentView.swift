import SwiftUI
import SwiftData

struct ContentView: View {
    @Query var rounds: [Round]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Golf Rounds")
                    .font(.headline)
                
                if rounds.isEmpty {
                    Text("No rounds yet")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    List(rounds.sorted { $0.date > $1.date }.prefix(5)) { round in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Score: \(round.totalScore)")
                                .font(.caption)
                                .bold()
                            Text(round.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    ContentView()
}

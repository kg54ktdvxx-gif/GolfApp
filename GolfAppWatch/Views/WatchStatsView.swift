import SwiftUI
import GolfKit

struct WatchStatsView: View {
    let rounds: [Round]
    private let statsService = StatsService()
    
    typealias RoundStats = StatsService.Stats
    
    var stats: RoundStats {
        statsService.calculateStats(rounds: rounds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Stats")
                .font(.headline)
            
            if rounds.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    Text("No rounds")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        // Summary stats
                        StatRow(label: "Rounds", value: "\(stats.rounds)")
                        StatRow(label: "Avg", value: String(format: "%.1f", stats.avgScore))
                        StatRow(label: "Best", value: "\(stats.bestScore ?? 0)")
                        StatRow(label: "GIR", value: "\(stats.girCount)")
                        
                        Divider()
                        
                        // Recent rounds
                        Text("Recent")
                            .font(.caption)
                            .bold()
                        
                        ForEach(rounds.sorted { $0.date > $1.date }.prefix(3)) { round in
                            HStack(spacing: 4) {
                                Text(round.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                                Spacer()
                                Text("\(round.totalScore)")
                                    .font(.caption)
                                    .bold()
                            }
                            .padding(4)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                        }
                    }
                    .padding(8)
                }
            }
        }
        .padding(8)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.caption)
                .bold()
        }
    }
}

#Preview {
    WatchStatsView(rounds: [])
}

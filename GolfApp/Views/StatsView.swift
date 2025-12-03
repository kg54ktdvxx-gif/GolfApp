import SwiftUI
import SwiftData
import GolfKit

struct StatsView: View {
    @Query var rounds: [Round]
    private let statsService = StatsService()
    
    typealias RoundStats = StatsService.Stats
    
    var stats: RoundStats {
        statsService.calculateStats(rounds: rounds)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if rounds.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No rounds yet")
                            .font(.headline)
                        Text("Start a round to see your stats")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Summary cards
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Rounds",
                                    value: "\(stats.rounds)",
                                    icon: "18.circle"
                                )
                                
                                StatCard(
                                    title: "Avg Score",
                                    value: String(format: "%.1f", stats.avgScore),
                                    icon: "target"
                                )
                            }
                            
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Best",
                                    value: "\(stats.bestScore ?? 0)",
                                    icon: "star.fill"
                                )
                                
                                StatCard(
                                    title: "GIR",
                                    value: "\(stats.girCount)",
                                    icon: "checkmark.circle"
                                )
                            }
                            
                            
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Total Putts",
                                    value: "\(stats.totalPutts)",
                                    icon: "circle.fill"
                                )
                                
                                StatCard(
                                    title: "Avg Putts",
                                    value: String(format: "%.1f", stats.avgPutts),
                                    icon: "divide"
                                )
                            }
                            
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Fairways Hit",
                                    value: "\(stats.totalFairwaysHit)",
                                    icon: "flag.fill"
                                )
                                
                                StatCard(
                                    title: "Fairway %",
                                    value: String(format: "%.1f%%", stats.fairwayHitPercentage),
                                    icon: "percent"
                                )
                            }
                            }
                            
                            // Score history chart
                            ScoreHistoryChart(rounds: rounds)
                            
                            // Recent rounds
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Rounds")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(rounds.sorted { $0.date > $1.date }.prefix(5)) { round in
                                    RoundRow(round: round)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(.blue)
            }
            
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct RoundRow: View {
    let round: Round
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Score: \(round.totalScore)")
                    .font(.headline)
                Text(round.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("GIR: \(round.girCount)")
                    .font(.caption)
                Text("Putts: \(round.totalPutts)")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    StatsView()
}

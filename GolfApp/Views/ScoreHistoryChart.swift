import SwiftUI
import Charts
import GolfKit

struct ScoreHistoryChart: View {
    let rounds: [Round]
    private let statsService = StatsService()
    
    var scoreHistory: [(date: Date, score: Int)] {
        statsService.getScoreHistory(rounds: rounds)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score History")
                .font(.headline)
                .padding(.horizontal)
            
            if scoreHistory.isEmpty {
                Text("No score history available")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart(scoreHistory, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Score", item.score)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("Score", item.score)
                    )
                    .foregroundStyle(.blue)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
                .padding()
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ScoreHistoryChart(rounds: [])
}

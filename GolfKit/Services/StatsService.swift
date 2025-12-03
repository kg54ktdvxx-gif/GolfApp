import Foundation
import SwiftData

@MainActor
public final class StatsService {
    
    public init() {}
    
    public struct Stats {
        public var roundsPlayed: Int
        public var averageScore: Double
        public var bestScore: Int
    }
    
    public func calculateStats(rounds: [Round]) -> Stats {
        let played = rounds.count
        guard played > 0 else {
            return Stats(roundsPlayed: 0, averageScore: 0, bestScore: 0)
        }
        
        let totalScore = rounds.reduce(0) { $0 + $1.totalScore }
        let avg = Double(totalScore) / Double(played)
        let best = rounds.map { $0.totalScore }.min() ?? 0
        
        return Stats(roundsPlayed: played, averageScore: avg, bestScore: best)
    }
}

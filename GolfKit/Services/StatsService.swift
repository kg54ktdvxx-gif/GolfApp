import Foundation
import SwiftData

@MainActor
public final class StatsService {
    
    public init() {}
    
    public struct Stats {
        public var rounds: Int
        public var avgScore: Double
        public var bestScore: Int?
        public var girCount: Int
        public var totalPutts: Int
        public var avgPutts: Double
        public var fairwayHitPercentage: Double
        public var totalFairwaysHit: Int
    }
    
    public func calculateStats(rounds: [Round]) -> Stats {
        let played = rounds.count
        guard played > 0 else {
            return Stats(rounds: 0, avgScore: 0, bestScore: nil, girCount: 0, totalPutts: 0, avgPutts: 0, fairwayHitPercentage: 0, totalFairwaysHit: 0)
        }
        
        let totalScore = rounds.reduce(0) { $0 + $1.totalScore }
        let avg = Double(totalScore) / Double(played)
        let best = rounds.map { $0.totalScore }.min()
        
        let totalGIR = rounds.reduce(0) { $0 + $1.girCount }
        let totalPutts = rounds.reduce(0) { $0 + $1.totalPutts }
        let avgPutts = Double(totalPutts) / Double(played)
        
        // Calculate fairway stats (only count par 4s and 5s, typically 14 holes per round)
        let totalFairwaysHit = rounds.reduce(0) { $0 + $1.fairways.filter { $0 }.count }
        let totalFairwayOpportunities = rounds.reduce(0) { $0 + $1.fairways.count }
        let fairwayPercentage = totalFairwayOpportunities > 0 ? (Double(totalFairwaysHit) / Double(totalFairwayOpportunities)) * 100 : 0
        
        return Stats(
            rounds: played,
            avgScore: avg,
            bestScore: best,
            girCount: totalGIR,
            totalPutts: totalPutts,
            avgPutts: avgPutts,
            fairwayHitPercentage: fairwayPercentage,
            totalFairwaysHit: totalFairwaysHit
        )
    }
    
    /// Get score history for charting
    /// Returns array of (date, score) tuples sorted by date
    public func getScoreHistory(rounds: [Round]) -> [(date: Date, score: Int)] {
        return rounds
            .map { ($0.date, $0.totalScore) }
            .sorted { $0.date < $1.date }
    }
}

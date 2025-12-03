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
    }
    
    public func calculateStats(rounds: [Round]) -> Stats {
        let played = rounds.count
        guard played > 0 else {
            return Stats(rounds: 0, avgScore: 0, bestScore: nil, girCount: 0, totalPutts: 0, avgPutts: 0)
        }
        
        let totalScore = rounds.reduce(0) { $0 + $1.totalScore }
        let avg = Double(totalScore) / Double(played)
        let best = rounds.map { $0.totalScore }.min()
        
        let totalGIR = rounds.reduce(0) { $0 + $1.girCount }
        let totalPutts = rounds.reduce(0) { $0 + $1.totalPutts }
        let avgPutts = Double(totalPutts) / Double(played)
        
        return Stats(
            rounds: played,
            avgScore: avg,
            bestScore: best,
            girCount: totalGIR,
            totalPutts: totalPutts,
            avgPutts: avgPutts
        )
    }
}

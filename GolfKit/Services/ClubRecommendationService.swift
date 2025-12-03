import Foundation
import SwiftData

@MainActor
public final class ClubRecommendationService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Recommend a club based on distance and user's historical performance
    /// - Parameter targetDistance: The distance to the target in yards
    /// - Returns: Recommended club, or nil if no suitable club found
    public func recommendClub(for targetDistance: Int) throws -> Club? {
        let descriptor = FetchDescriptor<Club>(
            sortBy: [SortDescriptor(\.averageDistance)]
        )
        let clubs = try modelContext.fetch(descriptor)
        
        // Find the club with average distance closest to target
        return clubs.min(by: { abs($0.averageDistance - targetDistance) < abs($1.averageDistance - targetDistance) })
    }
    
    /// Get all clubs for the user
    public func getAllClubs() throws -> [Club] {
        let descriptor = FetchDescriptor<Club>(
            sortBy: [SortDescriptor(\.type), SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Update club's average distance based on shot history
    /// - Parameter clubId: The club to update
    public func updateClubAverageDistance(clubId: String) throws {
        // Fetch all shots with this club
        let shotDescriptor = FetchDescriptor<Shot>(
            predicate: #Predicate { $0.clubId == clubId }
        )
        let shots = try modelContext.fetch(shotDescriptor)
        
        guard !shots.isEmpty else { return }
        
        // Calculate average distance
        let totalDistance = shots.reduce(0) { $0 + $1.distance }
        let averageDistance = totalDistance / shots.count
        
        // Update the club
        let clubDescriptor = FetchDescriptor<Club>(
            predicate: #Predicate { $0.id == clubId }
        )
        guard let club = try modelContext.fetch(clubDescriptor).first else { return }
        
        club.averageDistance = averageDistance
        try modelContext.save()
    }
    
    /// Get performance stats for a specific club
    public func getClubStats(clubId: String) throws -> ClubStats {
        let descriptor = FetchDescriptor<Shot>(
            predicate: #Predicate { $0.clubId == clubId }
        )
        let shots = try modelContext.fetch(descriptor)
        
        let totalShots = shots.count
        let averageDistance = totalShots > 0 ? shots.reduce(0) { $0 + $1.distance } / totalShots : 0
        let maxDistance = shots.map { $0.distance }.max() ?? 0
        let minDistance = shots.map { $0.distance }.min() ?? 0
        
        return ClubStats(
            totalShots: totalShots,
            averageDistance: averageDistance,
            maxDistance: maxDistance,
            minDistance: minDistance
        )
    }
    
    public struct ClubStats {
        public let totalShots: Int
        public let averageDistance: Int
        public let maxDistance: Int
        public let minDistance: Int
    }
}

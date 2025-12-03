import Foundation
import SwiftData

@Model
public final class Shot {
    @Attribute(.unique) public var id: String
    public var roundId: String
    public var holeNumber: Int
    public var clubId: String?
    public var distance: Int = 0 // Distance in yards
    public var result: ShotResult
    public var timestamp: Date
    
    public init(id: String = UUID().uuidString, roundId: String, holeNumber: Int, clubId: String? = nil, distance: Int = 0, result: ShotResult = .other, timestamp: Date = Date()) {
        self.id = id
        self.roundId = roundId
        self.holeNumber = holeNumber
        self.clubId = clubId
        self.distance = distance
        self.result = result
        self.timestamp = timestamp
    }
}

public enum ShotResult: String, Codable {
    case fairway
    case rough
    case bunker
    case green
    case hole
    case other
    
    public var displayName: String {
        switch self {
        case .fairway: return "Fairway"
        case .rough: return "Rough"
        case .bunker: return "Bunker"
        case .green: return "Green"
        case .hole: return "Hole"
        case .other: return "Other"
        }
    }
}

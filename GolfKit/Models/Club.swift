import Foundation
import SwiftData

@Model
public final class Club {
    @Attribute(.unique) public var id: String
    public var name: String
    public var type: ClubType
    public var averageDistance: Int = 0 // Average distance in yards
    public var userId: String? // For multi-user support in the future
    
    public init(id: String = UUID().uuidString, name: String, type: ClubType, averageDistance: Int = 0, userId: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.averageDistance = averageDistance
        self.userId = userId
    }
}

public enum ClubType: String, Codable {
    case driver
    case wood
    case hybrid
    case iron
    case wedge
    case putter
    
    public var displayName: String {
        switch self {
        case .driver: return "Driver"
        case .wood: return "Wood"
        case .hybrid: return "Hybrid"
        case .iron: return "Iron"
        case .wedge: return "Wedge"
        case .putter: return "Putter"
        }
    }
}

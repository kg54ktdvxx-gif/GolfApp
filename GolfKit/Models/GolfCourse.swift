import Foundation
import SwiftData
import CoreLocation

@Model
public final class GolfCourse {
    @Attribute(.unique) public var id: String
    public var name: String
    public var lat: Double
    public var lon: Double
    public var location: String? // Renamed from address
    public var handicap: Int = 0 // Placeholder for course handicap/rating
    public var holes: [Hole]
    
    public var par: Int {
        holes.reduce(0) { $0 + $1.par }
    }
    
    public init(id: String = UUID().uuidString, name: String, lat: Double, lon: Double, location: String? = nil, handicap: Int = 0, holes: [Hole] = []) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
        self.location = location
        self.handicap = handicap
        self.holes = holes
    }
}

@Model
public final class Hole {
    @Attribute(.unique) public var id: String
    public var number: Int
    public var par: Int
    public var handicap: Int
    public var distance: Int // in yards/meters
    
    public var averageYardage: Int {
        distance
    }
    
    // Coordinates for the green center, front, back could be added here
    public var lat: Double?
    public var lon: Double?
    
    public init(id: String = UUID().uuidString, number: Int, par: Int, handicap: Int, distance: Int, lat: Double? = nil, lon: Double? = nil) {
        self.id = id
        self.number = number
        self.par = par
        self.handicap = handicap
        self.distance = distance
        self.lat = lat
        self.lon = lon
    }
}

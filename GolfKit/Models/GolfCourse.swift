import Foundation
import SwiftData
import CoreLocation

@Model
public final class GolfCourse {
    @Attribute(.unique) public var id: String
    public var name: String
    public var lat: Double
    public var lon: Double
    public var address: String?
    public var holes: [Hole]
    
    public init(id: String = UUID().uuidString, name: String, lat: Double, lon: Double, address: String? = nil, holes: [Hole] = []) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
        self.address = address
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

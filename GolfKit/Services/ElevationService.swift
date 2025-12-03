import Foundation

@MainActor
public final class ElevationService {
    
    public init() {}
    
    /// Calculate the "plays like" distance based on elevation change
    /// Formula: 1 yard per 10 feet of elevation change
    /// - Parameters:
    ///   - actualDistance: The measured distance in yards
    ///   - elevationChange: Elevation change in feet (positive = uphill, negative = downhill)
    /// - Returns: Adjusted distance that accounts for elevation
    public func calculatePlaysLikeDistance(actualDistance: Int, elevationChange: Int) -> Int {
        let adjustment = elevationChange / 10
        return actualDistance + adjustment
    }
    
    /// Calculate elevation change between two points
    /// - Parameters:
    ///   - startElevation: Starting elevation in feet
    ///   - endElevation: Ending elevation in feet
    /// - Returns: Elevation change (positive = uphill, negative = downhill)
    public func calculateElevationChange(from startElevation: Double, to endElevation: Double) -> Int {
        return Int(endElevation - startElevation)
    }
    
    /// Get a human-readable description of the elevation change
    /// - Parameter elevationChange: Elevation change in feet
    /// - Returns: Description like "15 ft uphill" or "10 ft downhill"
    public func elevationDescription(_ elevationChange: Int) -> String {
        if elevationChange == 0 {
            return "Level"
        } else if elevationChange > 0 {
            return "\(elevationChange) ft uphill"
        } else {
            return "\(abs(elevationChange)) ft downhill"
        }
    }
}

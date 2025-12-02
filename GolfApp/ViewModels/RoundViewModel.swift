import Foundation
import SwiftData
import CoreLocation

/// View model for managing a single round of golf.
/// Handles score tracking, GPS updates, and persistence.
@MainActor
final class RoundViewModel: ObservableObject {
    @Published var round: Round?
    @Published var currentHole: Int = 1
    @Published var gpsDistance: Int = 0
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    let course: GolfCourse
    let modelContext: ModelContext
    private let locationService: LocationService
    private let statsService = StatsService()
    
    init(
        course: GolfCourse,
        modelContext: ModelContext,
        locationService: LocationService = LocationService()
    ) {
        self.course = course
        self.modelContext = modelContext
        self.locationService = locationService
    }
    
    // MARK: - Public Methods
    
    /// Start a new round
    func startRound() {
        round = Round(
            id: UUID().uuidString,
            courseId: course.id,
            date: Date(),
            scores: Array(repeating: 0, count: 18)
        )
        currentHole = 1
        error = nil
        
        locationService.requestLocationPermission()
        locationService.startUpdatingLocation()
        updateGPS()
    }
    
    /// Record score for current hole and move to next
    /// - Parameter score: Score for the hole (2-10)
    func recordScore(_ score: Int) {
        guard var r = round else { return }
        guard score >= 2 && score <= 10 else {
            error = "Score must be between 2 and 10"
            return
        }
        
        r.scores[currentHole - 1] = score
        round = r
        
        if currentHole < 18 {
            currentHole += 1
            updateGPS()
        }
        
        error = nil
    }
    
    /// Edit score for a specific hole
    /// - Parameters:
    ///   - hole: Hole number (1-18)
    ///   - score: New score
    func editScore(hole: Int, score: Int) {
        guard var r = round else { return }
        guard hole >= 1 && hole <= 18 else {
            error = "Invalid hole number"
            return
        }
        guard score >= 2 && score <= 10 else {
            error = "Score must be between 2 and 10"
            return
        }
        
        r.scores[hole - 1] = score
        round = r
        error = nil
    }
    
    /// Undo last score entry
    func undoLastScore() {
        guard var r = round else { return }
        guard currentHole > 1 else {
            error = "Cannot undo on first hole"
            return
        }
        
        currentHole -= 1
        r.scores[currentHole - 1] = 0
        round = r
        updateGPS()
        error = nil
    }
    
    /// Finish the round and save to database
    func finishRound() {
        guard let r = round else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            modelContext.insert(r)
            try modelContext.save()
            error = nil
        } catch {
            self.error = "Failed to save round: \(error.localizedDescription)"
        }
    }
    
    /// Get current hole information
    var currentHoleInfo: Hole? {
        guard currentHole >= 1 && currentHole <= course.holes.count else { return nil }
        return course.holes[currentHole - 1]
    }
    
    /// Get current round stats
    var currentStats: RoundStats? {
        guard let r = round else { return nil }
        return statsService.calculateStats(rounds: [r])
    }
    
    // MARK: - Private Methods
    
    private func updateGPS() {
        Task {
            do {
                let distance = locationService.getDistance(
                    to: CLLocationCoordinate2D(latitude: course.lat, longitude: course.lon)
                )
                self.gpsDistance = distance
            } catch {
                self.error = "GPS update failed: \(error.localizedDescription)"
            }
        }
    }
}

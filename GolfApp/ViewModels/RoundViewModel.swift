import Foundation
import SwiftData
import CoreLocation
import GolfKit

/// Manages the state and logic for an active golf round.
/// Thread-safe and designed for reactive UI updates.
@MainActor
final class RoundViewModel: ObservableObject {
    @Published var round: Round?
    @Published var currentHole: Int = 1
    @Published var gpsDistance: Int = 0
    @Published var error: LocationError?
    @Published var isLoadingLocation: Bool = false
    
    let course: GolfCourse
    let modelContext: ModelContext
    private let locationService: LocationService
    private var locationUpdateTask: Task<Void, Never>?
    
    init(
        course: GolfCourse,
        modelContext: ModelContext,
        locationService: LocationService
    ) {
        self.course = course
        self.modelContext = modelContext
        self.locationService = locationService
    }
    
    deinit {
        locationUpdateTask?.cancel()
        locationService.stopUpdatingLocation()
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
        
        locationService.requestLocationPermission()
        updateGPS()
    }
    
    /// Record score for current hole and advance to next
    /// - Parameter score: Score for the hole (2-10)
    func recordScore(_ score: Int) {
        guard var r = round else { return }
        guard currentHole <= 18 else { return }
        
        r.scores[currentHole - 1] = score
        round = r
        
        if currentHole < 18 {
            currentHole += 1
            updateGPS()
        }
    }
    
    /// Undo the last score and go back to previous hole
    func undoScore() {
        guard currentHole > 1 else { return }
        currentHole -= 1
        updateGPS()
    }
    
    /// Save the completed round to persistent storage
    func finishRound() throws {
        guard let r = round else {
            throw NSError(domain: "RoundViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No active round"])
        }
        
        modelContext.insert(r)
        try modelContext.save()
    }
    
    // MARK: - Private Methods
    
    private func updateGPS() {
        locationUpdateTask?.cancel()
        
        locationUpdateTask = Task {
            isLoadingLocation = true
            error = nil
            
            do {
                let location = try await locationService.getCurrentLocation()
                let courseLocation = CLLocationCoordinate2D(latitude: course.lat, longitude: course.lon)
                gpsDistance = locationService.getDistance(to: courseLocation)
            } catch let locationError as LocationError {
                self.error = locationError
            } catch {
                self.error = .locationFailed(error.localizedDescription)
            }
            
            isLoadingLocation = false
        }
    }
}

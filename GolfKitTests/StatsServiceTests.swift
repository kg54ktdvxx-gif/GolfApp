import XCTest
@testable import GolfKit

@MainActor
final class StatsServiceTests: XCTestCase {
    var sut: StatsService!
    
    override func setUp() async throws {
        sut = StatsService()
    }
    
    override func tearDown() async throws {
        sut = nil
    }
    
    func testCalculateStats_WithEmptyRounds_ReturnsZeroStats() {
        // When
        let stats = sut.calculateStats(rounds: [])
        
        // Then
        XCTAssertEqual(stats.rounds, 0)
        XCTAssertEqual(stats.avgScore, 0)
        XCTAssertNil(stats.bestScore)
        XCTAssertEqual(stats.girCount, 0)
        XCTAssertEqual(stats.totalPutts, 0)
        XCTAssertEqual(stats.avgPutts, 0)
    }
    
    func testCalculateStats_WithSingleRound_ReturnsCorrectStats() {
        // Given
        let round = Round(
            courseId: "test",
            scores: Array(repeating: 4, count: 18),
            putts: Array(repeating: 2, count: 18),
            gir: Array(repeating: true, count: 9) + Array(repeating: false, count: 9)
        )
        
        // When
        let stats = sut.calculateStats(rounds: [round])
        
        // Then
        XCTAssertEqual(stats.rounds, 1)
        XCTAssertEqual(stats.avgScore, 72)
        XCTAssertEqual(stats.bestScore, 72)
        XCTAssertEqual(stats.girCount, 9)
        XCTAssertEqual(stats.totalPutts, 36)
        XCTAssertEqual(stats.avgPutts, 36)
    }
    
    func testCalculateStats_WithMultipleRounds_ReturnsCorrectAverages() {
        // Given
        let round1 = Round(
            courseId: "test",
            scores: Array(repeating: 4, count: 18),
            putts: Array(repeating: 2, count: 18),
            gir: Array(repeating: true, count: 10) + Array(repeating: false, count: 8)
        )
        let round2 = Round(
            courseId: "test",
            scores: Array(repeating: 5, count: 18),
            putts: Array(repeating: 2, count: 18),
            gir: Array(repeating: true, count: 8) + Array(repeating: false, count: 10)
        )
        
        // When
        let stats = sut.calculateStats(rounds: [round1, round2])
        
        // Then
        XCTAssertEqual(stats.rounds, 2)
        XCTAssertEqual(stats.avgScore, 81) // (72 + 90) / 2
        XCTAssertEqual(stats.bestScore, 72)
        XCTAssertEqual(stats.girCount, 18) // 10 + 8
        XCTAssertEqual(stats.totalPutts, 72) // 36 + 36
        XCTAssertEqual(stats.avgPutts, 36) // 72 / 2
    }
    
    func testCalculateStats_WithVariedScores_ReturnsCorrectBestScore() {
        // Given
        let round1 = Round(courseId: "test", scores: Array(repeating: 5, count: 18))
        let round2 = Round(courseId: "test", scores: Array(repeating: 4, count: 18))
        let round3 = Round(courseId: "test", scores: Array(repeating: 6, count: 18))
        
        // When
        let stats = sut.calculateStats(rounds: [round1, round2, round3])
        
        // Then
        XCTAssertEqual(stats.bestScore, 72) // 4 * 18
    }
    
    func testCalculateStats_WithNoGIR_ReturnsZeroGIRCount() {
        // Given
        let round = Round(
            courseId: "test",
            scores: Array(repeating: 4, count: 18),
            gir: Array(repeating: false, count: 18)
        )
        
        // When
        let stats = sut.calculateStats(rounds: [round])
        
        // Then
        XCTAssertEqual(stats.girCount, 0)
    }
}

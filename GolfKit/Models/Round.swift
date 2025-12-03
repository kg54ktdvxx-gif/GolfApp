import Foundation
import SwiftData

@Model
public final class Round {
    @Attribute(.unique) public var id: String
    public var courseId: String
    public var date: Date
    public var scores: [Int] // Array of scores for 18 holes
    public var putts: [Int]
    public var fairways: [Bool]
    public var gir: [Bool]
    
    // Computed property for total score
    public var totalScore: Int {
        scores.reduce(0, +)
    }
    
    public var totalPutts: Int {
        putts.reduce(0, +)
    }
    
    public var girCount: Int {
        gir.filter { $0 }.count
    }
    
    public init(id: String = UUID().uuidString, courseId: String, date: Date = Date(), scores: [Int] = Array(repeating: 0, count: 18), putts: [Int] = Array(repeating: 0, count: 18), fairways: [Bool] = Array(repeating: false, count: 18), gir: [Bool] = Array(repeating: false, count: 18)) {
        self.id = id
        self.courseId = courseId
        self.date = date
        self.scores = scores
        self.putts = putts
        self.fairways = fairways
        self.gir = gir
    }
}

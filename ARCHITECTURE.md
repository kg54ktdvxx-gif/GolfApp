# GolfApp Architecture

## Overview

GolfApp follows **MVVM + Clean Architecture** principles with a shared framework approach for iOS and watchOS.

```
┌─────────────────────────────────────────┐
│         iOS App / watchOS App           │
├─────────────────────────────────────────┤
│  Views (SwiftUI)                        │
│  ├─ CourseSearchView                    │
│  ├─ RoundScoringView                    │
│  └─ StatsView                           │
├─────────────────────────────────────────┤
│  ViewModels (@MainActor)                │
│  ├─ RoundViewModel                      │
│  └─ (More to come)                      │
├─────────────────────────────────────────┤
│         GolfKit Framework               │
│  ┌─────────────────────────────────┐   │
│  │ Models (SwiftData)              │   │
│  │ ├─ GolfCourse                   │   │
│  │ ├─ Hole                         │   │
│  │ ├─ Round                        │   │
│  │ └─ RoundStats                   │   │
│  ├─────────────────────────────────┤   │
│  │ Services (@MainActor)           │   │
│  │ ├─ CourseService                │   │
│  │ ├─ LocationService              │   │
│  │ └─ StatsService                 │   │
│  └─────────────────────────────────┘   │
├─────────────────────────────────────────┤
│  Local Storage (SwiftData)              │
│  └─ Persistent Models                   │
└─────────────────────────────────────────┘
```

---

## Layer Responsibilities

### Views (SwiftUI)

**Responsibility:** Display data and handle user interactions.

```swift
struct CourseSearchView: View {
    @State private var searchText = ""
    @Environment(CourseService.self) var courseService
    
    var body: some View {
        // Display courses, handle search
    }
}
```

**Rules:**
- No business logic
- No service creation
- Inject services via `@Environment`
- Handle loading/error states

### ViewModels

**Responsibility:** Manage state and coordinate between views and services.

```swift
@MainActor
final class RoundViewModel: ObservableObject {
    @Published var round: Round?
    @Published var currentHole: Int = 1
    
    func recordScore(_ score: Int) { ... }
    func finishRound() throws { ... }
}
```

**Rules:**
- `@MainActor` for thread safety
- `@Published` for reactive updates
- Dependency injection in init
- Proper cleanup in deinit

### Models (GolfKit)

**Responsibility:** Represent domain data.

```swift
@Model
final class Round {
    var id: String
    var scores: [Int]
    
    var totalScore: Int {
        scores.reduce(0, +)
    }
}
```

**Rules:**
- `@Model` for SwiftData persistence
- `@Attribute(.unique)` on IDs
- Computed properties for derived data
- Codable for serialization

### Services (GolfKit)

**Responsibility:** Handle business logic and external interactions.

```swift
@MainActor
final class CourseService {
    func searchCourses(query: String) async throws -> [GolfCourse]
    func getCourse(id: String) throws -> GolfCourse
}
```

**Rules:**
- `@MainActor` for thread safety
- Typed errors (enums)
- Async/await for I/O
- Dependency injection
- Proper resource cleanup

---

## Data Flow

### 1. Course Search Flow

```
User types in SearchBar
    ↓
CourseSearchView updates @State searchText
    ↓
View calls courseService.searchCourses(query:)
    ↓
CourseService loads from bundle (cached)
    ↓
CourseService filters by query
    ↓
View displays results
```

### 2. Round Scoring Flow

```
User taps "Start Round"
    ↓
RoundViewModel.startRound()
    ↓
LocationService.requestLocationPermission()
    ↓
LocationService.getCurrentLocation() (async)
    ↓
RoundScoringView displays hole info + distance
    ↓
User records score
    ↓
RoundViewModel.recordScore(score)
    ↓
Round.scores updated
    ↓
Advance to next hole
    ↓
User finishes round
    ↓
RoundViewModel.finishRound()
    ↓
Round saved to SwiftData
```

### 3. Stats Flow

```
StatsView appears
    ↓
@Query fetches all Round objects
    ↓
StatsService.calculateStats(rounds:)
    ↓
Stats computed (avg, GIR, putts, etc.)
    ↓
View displays stats
```

---

## Dependency Injection

### App Level

```swift
@main
struct GolfAppApp: App {
    let courseService: CourseService
    let locationService: LocationService
    let statsService: StatsService
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(courseService)
                .environment(locationService)
                .environment(statsService)
        }
    }
}
```

### View Level

```swift
struct CourseSearchView: View {
    @Environment(CourseService.self) var courseService
}
```

### ViewModel Level

```swift
let vm = RoundViewModel(
    course: course,
    modelContext: modelContext,
    locationService: locationService
)
```

---

## Error Handling

### Typed Errors

```swift
enum CourseServiceError: LocalizedError {
    case fileNotFound
    case decodingError(String)
    case noCourseFound
    
    var errorDescription: String? { ... }
}
```

### Error Propagation

```swift
do {
    let courses = try await courseService.searchCourses(query: "")
} catch let error as CourseServiceError {
    self.error = error
} catch {
    self.error = .decodingError(error.localizedDescription)
}
```

### UI Error Display

```swift
if let error = error {
    ErrorView(error: error)
}
```

---

## Testing Strategy

### Unit Tests

```swift
func testCalculateStats() {
    let rounds = [mockRound1, mockRound2]
    let stats = sut.calculateStats(rounds: rounds)
    XCTAssertEqual(stats.rounds, 2)
}
```

### Integration Tests

```swift
func testRoundScoringFlow() async throws {
    // Start round
    // Record scores
    // Finish round
    // Verify saved
}
```

### Mock Services

```swift
class MockCourseService: CourseService {
    func searchCourses(query: String) async throws -> [GolfCourse] {
        return mockCourses
    }
}
```

---

## Performance Considerations

### Caching

- Courses cached in memory after first load
- Cache invalidation via `clearCache()`

### Async Operations

- Location requests are async
- Course loading is async
- No blocking on main thread

### Memory

- Proper cleanup in `deinit`
- Task cancellation on view disappear
- No retain cycles

---

## Future Improvements

1. **Backend Sync** - CloudKit for cloud persistence
2. **Premium Features** - RevenueCat for subscriptions
3. **Offline Support** - Sync rounds when online
4. **Analytics** - Track user behavior
5. **Notifications** - Remind users to play

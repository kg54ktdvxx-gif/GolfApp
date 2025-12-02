import SwiftUI

struct CourseDetailView: View {
    let course: GolfCourse
    @State private var showRoundView = false
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(course.name)
                    .font(.title2)
                    .bold()
                
                HStack {
                    Label(course.location, systemImage: "location.fill")
                        .font(.caption)
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Par")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(course.par)")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Handicap")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(course.handicap)")
                            .font(.headline)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Front 9")
                    .font(.headline)
                
                HStack(spacing: 8) {
                    ForEach(course.holes.prefix(9), id: \.id) { hole in
                        VStack(spacing: 4) {
                            Text("\(hole.number)")
                                .font(.caption2)
                            Text("Par \(hole.par)")
                                .font(.caption)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                    }
                }
                
                Text("Back 9")
                    .font(.headline)
                
                HStack(spacing: 8) {
                    ForEach(course.holes.suffix(9), id: \.id) { hole in
                        VStack(spacing: 4) {
                            Text("\(hole.number)")
                                .font(.caption2)
                            Text("Par \(hole.par)")
                                .font(.caption)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                    }
                }
            }
            .padding()
            
            Spacer()
            
            Button(action: { showRoundView = true }) {
                Text("Start Round")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .navigationDestination(isPresented: $showRoundView) {
                RoundScoringView(course: course)
            }
        }
        .navigationTitle("Course Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let mockCourse = GolfCourse(
        id: "test-1",
        name: "Pebble Beach",
        location: "Pebble Beach, CA",
        lat: 36.5627,
        lon: -121.9496,
        par: 72,
        handicap: 2,
        holes: []
    )
    CourseDetailView(course: mockCourse)
}

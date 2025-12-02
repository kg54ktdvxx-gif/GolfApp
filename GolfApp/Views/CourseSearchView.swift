import SwiftUI
import SwiftData

struct CourseSearchView: View {
    @StateObject private var vm: CourseListViewModel
    @Environment(\.modelContext) var modelContext
    
    init() {
        let container = try! ModelContainer(for: GolfCourse.self)
        let context = ModelContext(container)
        _vm = StateObject(wrappedValue: CourseListViewModel(modelContext: context))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $vm.searchText)
                    .padding()
                
                if vm.isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                } else if let error = vm.error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                    .padding()
                } else if vm.filteredCourses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "map.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No courses found")
                            .font(.headline)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    List(vm.filteredCourses) { course in
                        NavigationLink(destination: CourseDetailView(course: course)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(course.name)
                                    .font(.headline)
                                HStack {
                                    Text(course.location)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("Par \(course.par)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Courses")
            .onAppear {
                vm.loadCourses()
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search courses...", text: $text)
                .textFieldStyle(.roundedBorder)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    CourseSearchView()
}

import SwiftUI

struct PlantLibraryView: View {
    @StateObject private var store = PlantStore()
    @State private var searchText: String = ""
    @State private var selectedFilter = ""
    @State private var path: [Int] = []
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let filters = ["Low-Light", "Pet-Friendly", "Beginner", "Indoor"]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $searchText)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                Button {
                                    if selectedFilter == filter {
                                        selectedFilter = ""
                                    } else {
                                        selectedFilter = filter
                                    }
                                } label:  {
                                    Text(filter)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedFilter == filter ? Color(.darkGray) : Color.white
                                        )
                                        .foregroundColor(selectedFilter == filter ? .white : .black)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    Divider()
                }
                .background(Color.white)
            }
            Divider()
            
            // Content
            ScrollView {
                if store.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredPlants) { plant in
                            NavigationLink(value: plant.id) {
                                VStack {
                                    AsyncImage(url: URL(string: plant.default_image?.regular_url ?? "")) { img in
                                        img.resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color(.systemGray5)
                                    }
                                    .frame(width: 130, height: 130)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                                    
                                    Text(plant.displayName)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Plant Library")
            .navigationDestination(for: Int.self) { id in
                PlantDetailPlaceholder(plantID: id)
            }
        }
    }
    var filteredPlants: [PerenualPlant] {
        store.plants.filter { plant in
            let matchesSearch =
                searchText.isEmpty ||
                plant.common_name.lowercased().contains(searchText.lowercased()) ||
                plant.scientific_name.joined().lowercased().contains(searchText.lowercased())

            let matchesFilter = matchesSelectedFilter(plant)

            return matchesSearch && matchesFilter
        }
    }
    
    func matchesSelectedFilter(_ plant: PerenualPlant) -> Bool {
        guard !selectedFilter.isEmpty else { return true }

        switch selectedFilter {
        case "Low-Light":
            return plant.sunlight?.contains(where: {
                $0.lowercased().contains("low")
            }) ?? false

        case "Pet-Friendly":
            return plant.poisonous_to_pets == false

        case "Beginner":
            return plant.watering?.lowercased() == "average"
                || plant.watering?.lowercased() == "minimum"

        case "Indoor":
            return plant.indoor == true

        default:
            return true
        }
    }

}

#Preview {
    PlantLibraryView()
}

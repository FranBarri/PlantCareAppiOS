import SwiftUI

struct PlantLibraryView: View {
    @State private var searchText: String = ""
    @State private var selectedFilter = ""
    
    let filters = ["Low-Light", "Pet-Friendly", "Beginner", "Hardy"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
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
                                Button(action: { selectedFilter = filter }) {
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
            .navigationTitle("Plant Library")
        }
    }
}

#Preview {
    PlantLibraryView()
}

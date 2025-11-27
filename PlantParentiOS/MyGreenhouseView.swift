import SwiftUI

struct Plant: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    // Local asset name fallback
    let imageName: String
    // Remote image URL (preferred if available)
    let imageURL: String?
    let lastWatered: String
    let status: String
    let statusColor: Color

    init(id: UUID = UUID(), name: String, imageName: String, imageURL: String? = nil, lastWatered: String, status: String, statusColor: Color) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.imageURL = imageURL
        self.lastWatered = lastWatered
        self.status = status
        self.statusColor = statusColor
    }
}

struct MyGreenhouseView: View {
    @EnvironmentObject private var greenhouse: GreenhouseStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("My Greenhouse 🌿")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    
                    HStack {
                        Text("My Plants")
                            .font(.title2)
                            .bold()
                        Spacer()
                        if !greenhouse.plants.isEmpty {
                            Text("\(greenhouse.plants.count)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    if greenhouse.plants.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "leaf")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Your greenhouse is empty")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Add plants from the Home tab to see them here.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(greenhouse.plants) { plant in
                            PlantCardView(plant: plant)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGroupedBackground), Color(.systemGreen).opacity(0.15)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Session")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        greenhouse.clear()
                    }
                    .disabled(greenhouse.plants.isEmpty)
                }
            }
        }
    }
}

struct PlantCardView: View {
    let plant: Plant
    
    var body: some View {
        HStack {
            if let urlString = plant.imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)
            } else {
                Image(plant.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(plant.name)
                    .font(.headline)
                Text("Last watered: \(plant.lastWatered)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(plant.status)
                    .font(.subheadline)
                    .padding(5)
                    .background(plant.statusColor.opacity(0.2))
                    .foregroundColor(plant.statusColor)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct SessionAddRow: View {
    let plant: Plant
    var onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if let urlString = plant.imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(plant.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(plant.name)
                    .font(.subheadline)
                Text(plant.status)
                    .font(.caption)
                    .foregroundStyle(plant.statusColor)
            }
            Spacer()
            Button(action: onAdd) {
                Label("Add", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(8)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct GreenhouseView_Previews: PreviewProvider {
    static var previews: some View {
        MyGreenhouseView()
            .environmentObject(GreenhouseStore())
    }
}

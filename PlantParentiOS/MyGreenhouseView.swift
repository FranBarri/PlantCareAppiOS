import SwiftUI

struct MyGreenhouseView: View {
    @EnvironmentObject private var greenhouse: GreenhouseStore
    
    @State private var showRemoveAlert: Bool = false
    @State private var plantToRemove: GreenhousePlant? = nil
    
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
                            PlantCardView(plant: plant, onDelete: {
                                plantToRemove = plant
                                showRemoveAlert = true
                            }, onWatered: {
                                greenhouse.markWatered(for: plant)
                            })
                            .padding(.horizontal)
                            .id(plant.id)
                        }
                    }
                }
                .padding(.bottom, 50)
                .alert("Remove Plant?", isPresented: $showRemoveAlert, presenting: plantToRemove) { plant in
                    Button("Remove", role: .destructive) {
                        greenhouse.remove(plant)
                        plantToRemove = nil
                        showRemoveAlert = false
                    }
                    Button("Cancel", role: .cancel) { }
                } message: { plant in
                    Text("Are you sure you want to remove \"\(plant.displayName)\" from your greenhouse?")
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGroupedBackground), Color(.systemGreen).opacity(0.15)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

struct PlantCardView: View {
    let plant: GreenhousePlant
    var onDelete: () -> Void
    var onWatered: () -> Void
    
    var body: some View {
        HStack {
            if let urlString = plant.imageURL, !urlString.isEmpty, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.2)
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure(let error):
                        FallbackImageView(imageName: plant.imageName, plantName: plant.displayName, error: error, contentMode: .fit)
                    @unknown default:
                        if let name = plant.imageName, let uiImage = UIImage(named: name) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: "leaf.fill")
                                .resizable()
                        }
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)
                .id(plant.id)
            } else {
                if let name = plant.imageName, let uiImage = UIImage(named: name) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 5)
                        .id(plant.id)
                } else {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 5)
                        .id(plant.id)
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(plant.displayName)
                    .font(.headline)
                Text("Last watered: \(plant.lastWatered != nil ? Self.dateFormatter.string(from: plant.lastWatered!) : "Never")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("All good")
                    .font(.subheadline)
                    .padding(5)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                Button("Mark as Watered") {
                    onWatered()
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
}

// Helper fallback view that shows a local image and logs the async image error on appear.
struct FallbackImageView: View {
    let imageName: String?
    let plantName: String
    let error: Error?
    let contentMode: ContentMode

    var body: some View {
        Group {
            if let name = imageName, let uiImage = UIImage(named: name) {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                // Show a system placeholder if the named asset is missing
                Image(systemName: "leaf.fill")
                    .resizable()
                    .foregroundColor(.green)
            }
        }
        .aspectRatio(contentMode: contentMode)
        .onAppear {
            // Ignore cancelled requests (code -999) to avoid noisy logs
            if let urlError = error as? URLError, urlError.code == .cancelled { return }
            if let e = error {
                print("AsyncImage load error for \(plantName): \(e)")
            }
        }
    }
}

struct SessionAddRow: View {
    let plant: GreenhousePlant
    var onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if let urlString = plant.imageURL, !urlString.isEmpty, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.2)
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure(let error):
                        FallbackImageView(imageName: plant.imageName, plantName: plant.displayName, error: error, contentMode: .fill)
                    @unknown default:
                        if let name = plant.imageName, let uiImage = UIImage(named: name) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "leaf.fill")
                                .resizable()
                        }
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                if let name = plant.imageName, let uiImage = UIImage(named: name) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(plant.displayName)
                    .font(.subheadline)
                Text("All good")
                    .font(.caption)
                    .foregroundColor(.green)
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

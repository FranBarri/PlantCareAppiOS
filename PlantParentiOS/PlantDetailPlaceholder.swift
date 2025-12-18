import SwiftUI

struct PlantDetailPlaceholder: View {
    let plantID: Int
    @StateObject private var store = PlantStore()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var greenhouse: GreenhouseStore
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastIsError: Bool = false
    
    // Optional external callback
    var onAdd: ((PerenualPlantDetail) -> Void)? = nil
    
    var body: some View {
        Group {
            if store.isLoading {
                ProgressView().padding(.top, 40)
            } else if let plant = store.selectedPlantDetail {
                content(plant)
            } else {
                Text("Not found")
            }
        }
        .task {
            await store.fetchPlantDetail(id: plantID)
        }
    }
    
    @ViewBuilder
    private func content(_ plant: PerenualPlantDetail) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                }
                Spacer()
                Text(plant.displayName)
                    .font(.title2).bold()
                    .lineLimit(1)
                Spacer()
                Color.clear.frame(width: 44, height: 1)
            }
            .padding(.horizontal)
            .padding(.top, 60)
            
            // Scrollable content
            ScrollView {
                // Hero image
                AsyncImage(url: URL(string: plant.default_image?.regular_url ?? "")) { img in
                    img.resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color(.systemGray5))
                }
                .frame(height: 320)
                .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Quick tags
                    HStack(spacing: 12) {
                        TagCapsule(icon: "heart", text: plant.watering ?? "Frequent")
                        TagCapsule(icon: "sun.max", text: plant.sunLightText)
                    }
                    HStack(spacing: 12) {
                        let isIndoor = plant.indoor ?? true
                        if isIndoor {
                            TagCapsule(icon: "house", text: "Indoor Friendly")
                        } else {
                            TagCapsule(icon: "house", text: "Outdoor Preferred")
                        }
                        let petFlag = plant.poisonous_to_pets
                        if petFlag == 1 {
                            TagCapsule(icon: "pawprint", text: "Toxic to Pets")
                        } else {
                            TagCapsule(icon: "pawprint", text: "Pet Safe")
                        }
                    }
                    
                    // Detail sections
                    VStack(alignment: .leading, spacing: 10) {
                        Group {
                            Text("Watering")
                                .font(.headline)
                            Text("Follow the recommended schedule:\n\(plant.wateringFrequencyText). Adjust with light and temperature.")
                                .foregroundColor(.secondary)
                        }
                        Group {
                            Text("Sunlight")
                                .font(.headline)
                            Text("Sunlight should be: \(plant.sunLightText).")
                                .foregroundColor(.secondary)
                        }
                        Group {
                            Text("Indoor / Outdoor")
                                .font(.headline)
                            Text((plant.indoor ?? true) ? "This plant is suitable for indoor environments." : "This plant prefers outdoor environments.")
                                .foregroundColor(.secondary)
                        }
                        Group {
                            Text("Pet Safety")
                                .font(.headline)
                            if plant.poisonous_to_pets == 1 {
                                Text("This plant is toxic to pets. Place it out of reach of cats and dogs.")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("This plant is generally considered pet-safe.")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                .background(Color(.systemBackground))
                .padding(.bottom, 16) // extra bottom spacing
            }
        }
        .safeAreaInset(edge: .bottom) {
            // Bottom action bar with toast above the button
            VStack(spacing: 10) {
                if showToast {
                    HStack(spacing: 8) {
                        Image(systemName: toastIsError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text(toastMessage)
                            .foregroundColor(.white)
                            .font(.subheadline).bold()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(toastIsError ? Color.red : Color.green)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Button {
                    onAdd?(plant)
                    addToGreenhouse(from: plant)
                } label: {
                    Text("Add to My Plant")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background()
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // Add to greenhouse and show a short toast result
    private func addToGreenhouse(from detail: PerenualPlantDetail) {
        // Build display name: prefer common_name, fall back to first scientific_name
        let commonRaw = detail.common_name.trimmingCharacters(in: .whitespacesAndNewlines)
        let scientificRaw = detail.scientific_name.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let baseName = commonRaw.isEmpty ? (scientificRaw.isEmpty ? "Unknown" : scientificRaw) : commonRaw
        let name = baseName.localizedCapitalized
        
        // Prevent duplicates (case-insensitive)
        let exists = greenhouse.plants.contains { $0.name.lowercased() == name.lowercased() }
        if exists {
            toastMessage = "\(name) is already in your greenhouse"
            toastIsError = true
            withAnimation(.spring()) { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut) { showToast = false }
            }
            return
        }
        
        let imageURL = detail.default_image?.regular_url
        let imageName: String? = nil
        let lastWatered = "Today"
        let status = "All good"
        let statusColor: Color = .green
        
        let plant = Plant(
            id: UUID(),
            name: name,
            imageName: imageName,
            imageURL: imageURL,
            lastWatered: lastWatered,
            status: status,
            statusColor: statusColor
        )
        greenhouse.add(plant)
        
        toastMessage = "Added \(name) to your greenhouse"
        toastIsError = false
        withAnimation(.spring()) { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut) { showToast = false }
        }
    }
}

private struct TagCapsule: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    PlantDetailPlaceholder(plantID: 425)
        .environmentObject(GreenhouseStore())
}

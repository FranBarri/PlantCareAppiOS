import SwiftUI

struct PlantDetailPlaceholder: View {
    let plantID: Int
    @StateObject private var store = PlantStore()
    @Environment(\.dismiss) private var dismiss

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
        VStack(spacing: 10) {
            HStack {
                Button {
                    dismiss() // Back to library
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

            ScrollView {
                // image
                AsyncImage(url: URL(string: plant.default_image?.regular_url ?? "")) { img in
                    img.resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color(.systemGray5))
                }
                .frame(height: 320)
                .clipped()

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        // Watering
                        TagCapsule(icon: "heart", text: plant.watering ?? "Frequent")
                        // Sunlight
                        TagCapsule(icon: "sun.max", text: plant.sunLightText)
                    }
                    HStack(spacing: 12) {
                        // Indoor suitability
                        let isIndoor = plant.indoor ?? true
                        if isIndoor {
                            TagCapsule(icon: "house", text: "Indoor Friendly")
                        } else {
                            TagCapsule(icon: "house", text: "Outdoor Preferred")
                        }
                        
                        // Pet safety
                       
                        let petFlag = plant.poisonous_to_pets
                        if petFlag == 1 {
                            TagCapsule(icon: "pawprint", text: "Toxic to Pets")
                        } else {
                            TagCapsule(icon: "pawprint", text: "Pet Safe")
                        }
                        
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Watering")
                            .font(.headline)
                        Text("Follow the recommended schedule:\n\(plant.wateringFrequencyText). Adjust with light and temperature.")
                            .foregroundColor(.secondary)
                        Text("")
                        Text("Sunlight")
                            .font(.headline)
                        Text("Sunlight sholud be: \(plant.sunLightText).")
                            .foregroundColor(.secondary)
                    }

                    Button {
                        // TODO: Add to My Plant action
                    } label: {
                        Text("Add to My Plant")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                .background(Color(.systemBackground))
            }
        }
        .ignoresSafeArea(edges: .top)
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
}

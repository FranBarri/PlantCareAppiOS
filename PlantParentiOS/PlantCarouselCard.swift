import SwiftUI

struct PlantCarouselCard: View {
    let plant: PerenualPlant

    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: plant.default_image?.regular_url ?? "")) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(height: 140)
            .clipped()

            Text(plant.common_name)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(plant.sunlight?.first?.capitalized ?? "Any light")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button("Add to My Garden") { }
                    .buttonStyle(.bordered)
                    .tint(.green)
                Button("Browse Library") { }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

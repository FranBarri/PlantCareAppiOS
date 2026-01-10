import SwiftUI

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

import SwiftUI

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

import SwiftUI

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

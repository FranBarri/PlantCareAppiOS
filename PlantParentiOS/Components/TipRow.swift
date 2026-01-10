import SwiftUI

struct TipRow: View {
    let icon: String
    let title: String
    let text: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 30, alignment: .leading)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

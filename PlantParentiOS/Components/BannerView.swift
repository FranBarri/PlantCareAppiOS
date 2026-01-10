import SwiftUI

struct BannerView: View {
    let message: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .foregroundColor(.white)
            Text(message)
                .font(.subheadline).bold()
                .foregroundColor(.white)
            Spacer(minLength: 0)
            Button {
                withAnimation(.easeInOut) { }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.9))
            }
            .buttonStyle(.plain)
            .disabled(true) // non-interactive placeholder; can be wired to dismiss if desired
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.green)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

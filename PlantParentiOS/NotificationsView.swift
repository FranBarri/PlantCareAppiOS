import SwiftUI

enum NotificationType {
    case watering
    case tip
}

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let daysAgo: Int
    let imageName: String
    let type: NotificationType
    var isDone: Bool
}

struct NotificationsView: View {

    @State private var notifications = mockNotifications

    
    var body: some View {
        VStack(alignment: .leading) {

            Text("Notification")
                .font(.largeTitle)
                .bold()
                .padding()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(notifications) { item in
                        if item.type == .tip {
                            NotificationTipRow(item: item)
                        } else {
                            NotificationRow(item: item) {
                                markDone(item)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func markDone(_ item: AppNotification) {
        guard let index = notifications.firstIndex(where: { $0.id == item.id }) else { return }
        notifications[index].isDone = true
    }
}



#Preview {
    NotificationsView()
}


let mockNotifications: [AppNotification] = [
    .init(title: "Monstera",
          subtitle: "Needs water",
          daysAgo: 1,
          imageName: "Monstera",
          type: .watering,
          isDone: false),

    .init(title: "Snake Plant",
          subtitle: "Needs water",
          daysAgo: 1,
          imageName: "SnakePlant",
          type: .watering,
          isDone: false),

    .init(title: "Humidity tip",
          subtitle: "Mist plants or use a tray of water for humidity-loving plants.",
          daysAgo: 2,
          imageName: "person1",
          type: .tip,
          isDone: false),

    .init(title: "Onion",
          subtitle: "Needs water",
          daysAgo: 3,
          imageName: "Onion",
          type: .watering,
          isDone: true),
    
    .init(title: "Monstera",
          subtitle: "Needs water",
          daysAgo: 6,
          imageName: "Monstera",
          type: .watering,
          isDone: true),
    
    .init(title: "Overwatering tip",
          subtitle: "Yellow leaves can be a sign of too much water.",
          daysAgo: 1,
          imageName: "",
          type: .tip,
          isDone: false
        ),
    
    .init(title: "Snake Plant",
          subtitle: "Time to repot",
          daysAgo: 10,
          imageName: "SnakePlant",
          type: .watering,
          isDone: true
        )
]

struct NotificationRow: View {
    let item: AppNotification
    let onDone: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            // red dot (undone only)
            Circle()
                .fill(item.isDone ? Color.clear : Color.red)
                .frame(width: 8, height: 8)

            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                    Text("\(item.daysAgo)d")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }

                Text(item.subtitle)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }

            Spacer()

            // Done button only for watering + undone
            if item.type == .watering && !item.isDone {
                Button("Done") {
                    onDone()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
        }
        .padding(.vertical, 6)
        
    }
}

struct NotificationTipRow: View {
    let item: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            Image(systemName: "lightbulb.fill")
                .font(.title2)
                .foregroundColor(.green)
                .padding(10)
                .background(Color.green.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)

                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("\(item.daysAgo)d")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

import SwiftUI
import AVFoundation

var soundPlayer: AVAudioPlayer?

enum NotificationType: Equatable {
    case watering
    case tip(videoID: String)
}

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let daysAgo: Int
    let imageName: String
    var type: NotificationType
    var isDone: Bool
}

extension AppNotification {
    var youtubeVideoID: String {
        if case let .tip(videoID) = type {
            return videoID
        }
        return ""
    }
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
                        switch item.type {
                        case .watering:
                            NotificationRow(item: item) {
                                markDone(item)
                            }

                        case .tip(let videoID):
                            NotificationTipRow(item: item, videoID: videoID)
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
          type: .tip(videoID: "OXSMqyIgD08"),
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
          type: .tip(videoID: "dQw4w9WgXcQ"),
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
                    // Sound
                    playClickSound()
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

    private func playClickSound() {
        guard let path = Bundle.main.path(forResource: "button-press.mp3", ofType: nil) else {
            print("Sound file not found in bundle")
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.play()
        } catch {
            print("Failed to play sound:", error)
        }
    }
}

struct NotificationTipRow: View {
    let item: AppNotification
    let videoID: String

    @State private var showDetail = false

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
            
            Button {
                withAnimation {
                    showDetail.toggle()
                }
                
                playClickSound()
                
            } label: {
                Label("Video", systemImage: "chevron.right.circle")
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
                    .rotationEffect(.degrees(showDetail ? 90 : 0))
                    .scaleEffect(showDetail ? 1.5 : 1)
                    .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        
        if showDetail{
            YouTubeEmbed(videoID: item.youtubeVideoID)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 8)
                .padding(.horizontal)
                .padding(.bottom, 12)
                .transition(
                    .move(edge: .leading)
                    .combined(with: .opacity)
                    .combined(with: .scale(scale: 0.9))
                )
        }
    }

    private func playClickSound() {
        guard let path = Bundle.main.path(forResource: "button-press.mp3", ofType: nil) else {
            print("Sound file not found in bundle")
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.play()
        } catch {
            print("Failed to play sound:", error)
        }
    }
}

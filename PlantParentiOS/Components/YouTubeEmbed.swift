import SwiftUI
import YouTubePlayerKit
// https://github.com/SvenTiigi/YouTubePlayerKit.git

struct YouTubeEmbed: View {
    let videoID: String

    private var player: YouTubePlayer {
        YouTubePlayer(
            source: .video(id: videoID)
        )
    }

    var body: some View {
        YouTubePlayerView(player)
            .aspectRatio(16.0/9.0, contentMode: .fit)
    }
}

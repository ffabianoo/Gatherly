import SwiftUI

@ViewBuilder
func EventImageView(urlString: String?, height: CGFloat) -> some View {
    if let s = urlString, let url = URL(string: s) {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFill()
            case .failure(_):         Image("event_placeholder").resizable().scaledToFill()
            case .empty:
                ZStack { Rectangle().opacity(0.06); ProgressView() }
            @unknown default:          Image("event_placeholder").resizable().scaledToFill()
            }
        }
        .frame(height: height)
        .clipped()
    } else {
        Image("event_placeholder")
            .resizable()
            .scaledToFill()
            .frame(height: height)
            .clipped()
    }
}

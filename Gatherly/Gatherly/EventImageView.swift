import SwiftUI

@ViewBuilder
func EventImageView(urlString: String?, height: CGFloat) -> some View {
    if let s = urlString, let url = URL(string: s) {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFill()
            case .failure(_):         Rectangle().foregroundStyle(.gray)
            case .empty:              ZStack { Rectangle().opacity(0.06); ProgressView() }
            @unknown default:         Rectangle().foregroundStyle(.gray)
            }
        }
        .frame(height: height)
        .clipped()
    } else {
        Rectangle()
            .foregroundStyle(.gray)
            .frame(height: height)
            .clipped()
    }
}

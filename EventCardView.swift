import SwiftUI

struct EventCardView: View {
    let event: Event

    var body: some View {
        VStack(spacing: 0) {
            // Header image (remote via image_url)
            if let s = event.image_url, let url = URL(string: s) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle().fill(.gray.opacity(0.08))
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Rectangle().fill(.gray.opacity(0.2))
                    @unknown default:
                        Rectangle().fill(.gray.opacity(0.2))
                    }
                }
                .frame(height: 160)
                .clipped()
            } else {
                // Placeholder if no image_url
                Rectangle()
                    .fill(.gray.opacity(0.12))
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    )
            }

            // Text block
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)

                // Date (timestamp is a Date per Ticket 2)
                Text(event.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Location row
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(event.location)
                        .lineLimit(1)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.ultraThinMaterial)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08))
        )
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.title), \(event.timestamp.formatted(date: .abbreviated, time: .omitted)) at \(event.location)")
    }
}

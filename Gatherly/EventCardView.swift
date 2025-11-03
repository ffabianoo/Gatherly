import SwiftUI

struct EventCardView: View {
    let event: Event

    var body: some View {
        VStack(spacing: 0) {
            EventImageView(urlString: event.image_url, height: 160)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)

                if let date = event.parsedDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(event.timestamp)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.ultraThinMaterial)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08))
        }
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}


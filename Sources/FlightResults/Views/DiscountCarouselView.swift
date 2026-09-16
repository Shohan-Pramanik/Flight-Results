import SwiftUI

/// Dummy/hardcoded promo data — the API has nothing to do with this.
/// Tapping "Learn more" is the one real navigation in this task: it opens
/// gozayaan.com through the Coordinator.
struct DiscountCarouselView: View {
    private struct Promo: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
        let url: URL
    }

    let onLearnMore: (URL) -> Void

    private let promos: [Promo] = [
        Promo(title: "Save 15% on your next booking", systemImage: "tag.fill", url: URL(string: "https://gozayaan.com")!),
        Promo(title: "Bundle your hotel and save", systemImage: "building.2.fill", url: URL(string: "https://gozayaan.com")!)
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(promos) { promo in
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: promo.systemImage)
                            .font(.system(size: 28))
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text(promo.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(2)

                        Button("Learn more") {
                            onLearnMore(promo.url)
                        }
                        .font(.caption)
                    }
                    .frame(width: 180, alignment: .leading)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
                }
            }
        }
    }
}

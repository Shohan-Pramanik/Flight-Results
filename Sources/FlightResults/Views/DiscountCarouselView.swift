import SwiftUI

/// Dummy/hardcoded promo data — the API has nothing to do with this.
/// Tapping "Learn more" is the one real navigation in this task: it opens
/// gozayaan.com through the Coordinator. The same card is repeated three
/// times to fill the carousel, matching the design.
struct DiscountCarouselView: View {
    private struct Promo: Identifiable {
        let id: Int
        let title: String
        let url: URL
    }

    let onLearnMore: (URL) -> Void

    private let promos: [Promo] = (0..<3).map { index in
        Promo(id: index, title: "On International Flight Bookings", url: URL(string: "https://gozayaan.com")!)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(promos) { promo in
                    card(for: promo)
                }
            }
        }
    }

    private func card(for promo: Promo) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image("discountCardImg")
                .resizable()
                .frame(width: 64, height: 48)

            VStack(alignment: .leading, spacing: 0) {
                Text(promo.title)
                    .font(.custom("AvenirNext-DemiBold", size: 10))
                    .lineSpacing(4)
                Button {
                    onLearnMore(promo.url)
                } label: {
                    HStack(spacing: 2) {
                        Text("Learn more")
                            .font(.custom("AvenirNext-Medium", size: 8))
                            .underline()
                        Image(systemName: "arrow.up.right")
                            .resizable()
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(4)
        }
        .frame(width: 200, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color("DiscountCardMint")))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color("DiscountCardMint"), lineWidth: 1))
    }
}

import SwiftUI

private struct DateChip: Identifiable {
    let id = UUID()
    let dateLabel: String
    let priceLabel: String
}

/// Entirely dummy, hardcoded data per the spec — this strip doesn't depend
/// on search results. Taps are wired to a no-op rather than disabled, so
/// the fixed selection is clearly an intentional default, not a bug.
struct DatePriceStripView: View {
    private let chips: [DateChip] = [
        DateChip(dateLabel: "Mon 27 Sept", priceLabel: "USD 1,580"),
        DateChip(dateLabel: "Mon 28 Sept", priceLabel: "USD 1,980"),
        DateChip(dateLabel: "Tue 29 Sept", priceLabel: "USD 2,045"),
        DateChip(dateLabel: "Wed 30 Sept", priceLabel: "USD 2,129"),
        DateChip(dateLabel: "Thu 1 Oct", priceLabel: "USD 2,240"),
        DateChip(dateLabel: "Fri 2 Oct", priceLabel: "USD 2,310"),
        DateChip(dateLabel: "Sat 3 Oct", priceLabel: "USD 2,095")
    ]
    private let selectedIndex = 3

    @State private var containerWidth: CGFloat = 0

    var body: some View {
        ZStack(alignment: .trailing) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                            VStack(spacing: 4) {
                                Text(chip.dateLabel)
                                    .font(.custom("AvenirNext-Medium", size: 14))
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(index == selectedIndex ? Color("SelectedDateGold") : .white)
                                Text(chip.priceLabel)
                                    .font(.custom("AvenirNext-Medium", size: 14))
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(index == selectedIndex ? Color("SelectedDateGold") : .white.opacity(0.85))
                                Rectangle()
                                    .fill(index == selectedIndex ? Color("SelectedDateGold") : Color.clear)
                                    .frame(height: 2)
                            }
                            .id(index)
                            .onTapGesture {
                                // No-op: taps are ignored per the spec.
                            }
                        }
                    }
                    // Half-viewport-width margins on both ends guarantee any
                    // index (even the first/last chip) has enough room to
                    // reach the scroll view's true center — without this,
                    // ScrollViewReader clamps to content bounds and can't
                    // center chips near either edge of the content.
                    .padding(.horizontal, containerWidth / 2)
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear { containerWidth = geometry.size.width }
                    }
                )
                .onChange(of: containerWidth) { _ in
                    proxy.scrollTo(selectedIndex, anchor: .center)
                }
            }

            Image("priceGraph")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.horizontal, 16)
                .background(Color("AccentColor"))
        }
    }
}

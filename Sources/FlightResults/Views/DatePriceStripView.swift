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
    private let selectedIndex = 2

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                        VStack(spacing: 4) {
                            Text(chip.dateLabel)
                                .font(.custom("AvenirNext-Medium", size: 14))
                                .lineSpacing(6)
                                .tracking(0)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(index == selectedIndex ? Color("SelectedDateGold") : .white)
                            Text(chip.priceLabel)
                                .font(.custom("AvenirNext-Medium", size: 14))
                                .lineSpacing(6)
                                .tracking(0)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(index == selectedIndex ? Color("SelectedDateGold") : .white.opacity(0.85))
                            Rectangle()
                                .fill(index == selectedIndex ? Color("SelectedDateGold") : Color.clear)
                                .frame(height: 2)
                        }
                        .onTapGesture {
                            // No-op: taps are ignored per the spec.
                        }
                    }
                }
            }

            Image("priceGraph")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.horizontal, 16)
                .background(Color.accentColor)
        }
    }

    
}

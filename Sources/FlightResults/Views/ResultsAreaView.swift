import SwiftUI

/// The only part of the screen that changes shape across states.
struct ResultsAreaView: View {
    let state: FlightResultsState
    let onRetry: () -> Void
    let onSelect: (FlightOffer) -> Void
    let onLearnMore: (URL) -> Void

    var body: some View {
        switch state {
        case .loading:
            LazyVStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in FlightCardSkeletonView() }
            }
        case .success(let offers):
            LazyVStack(spacing: 12) {
                ForEach(ResultRowBuilder.rows(for: offers)) { row in
                    switch row {
                    case .flight(let offer):
                        FlightCardView(offer: offer)
                            .onTapGesture { onSelect(offer) }
                    case .promo:
                        DiscountCarouselView(onLearnMore: onLearnMore)
                    }
                }
            }
        case .empty:
            EmptyResultsView()
        case .error(let message):
            ErrorResultsView(message: message, onRetry: onRetry)
        }
    }
}

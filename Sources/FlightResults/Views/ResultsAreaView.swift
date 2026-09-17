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
            VStack(spacing: 20) {
                FlightSearchLoadingHeaderView()
                LazyVStack(spacing: 12) {
                    FlightCardSkeletonView()
                    FlightCardSkeletonView()
                    DiscountCarouselView(onLearnMore: onLearnMore)
                    FlightCardSkeletonView()
                    FlightCardSkeletonView()
                    FlightCardSkeletonView()
                }
            }
            .padding(.horizontal, 16)
        case .success(let offers):
            LazyVStack(spacing: 12) {
                ForEach(ResultRowBuilder.rows(for: offers)) { row in
                    switch row {
                    case .flight(let offer):
                        FlightCardView(offer: offer)
                            .padding(.horizontal, 16)
                            .onTapGesture { onSelect(offer) }
                    case .promo:
                        DiscountCarouselView(onLearnMore: onLearnMore)
                    }
                }
            }
        case .empty:
            EmptyResultsView()
                .padding(.horizontal, 16)
        case .error(let message):
            ErrorResultsView(message: message, onRetry: onRetry)
                .padding(.horizontal, 16)
        }
    }
}

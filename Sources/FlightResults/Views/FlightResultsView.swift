import SwiftUI

struct FlightResultsView: View {
    @ObservedObject var viewModel: FlightResultsViewModel

    var body: some View {
        VStack(spacing: 16) {
            RouteHeaderView(request: viewModel.request, onTapEdit: {})
            
            DatePriceStripView()

            SortFilterBarView(
                onSelectSort: { viewModel.applySort($0) },
                onTapFilter: {}
            )
            .zIndex(1)

            ScrollView {
                VStack(spacing: 16) {
                    ResultsAreaView(
                        state: viewModel.state,
                        onRetry: { Task { await viewModel.retry() } },
                        onSelect: { viewModel.selectFlight($0) },
                        onLearnMore: { viewModel.tapLearnMore(url: $0) }
                    )
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .task {
            await viewModel.load()
        }
        .background(Color.accentColor.ignoresSafeArea())
    }
}

import Foundation
import Combine

/// Owns the published screen state and the network call. Deliberately has
/// no import of UIKit navigation types and no reference to any Coordinator
/// type — it only reports through `FlightResultsCoordinatorDelegate`.
@MainActor
final class FlightResultsViewModel: ObservableObject {
    @Published private(set) var state: FlightResultsState = .loading

    weak var delegate: FlightResultsCoordinatorDelegate?

    let request: FlightSearchRequest

    private let service: FlightSearchServicing
    private var allOffers: [FlightOffer] = []

    /// `FlightResultsView.task` calls `load()` every time the view appears,
    /// including when it's just been re-exposed after a `NavigationStack`
    /// pop (e.g. returning from `WebLinkView`) — not only on first launch.
    /// This guard makes `load()` a one-shot: once a fetch has started, later
    /// calls are no-ops, so navigating away and back never re-fetches or
    /// re-shows the loading state. `retry()` bypasses the guard on purpose,
    /// since it's only ever invoked by an explicit user tap.
    private var hasLoaded = false

    init(request: FlightSearchRequest, service: FlightSearchServicing) {
        self.request = request
        self.service = service
    }

    func load() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        await performSearch()
    }

    func retry() async {
        await performSearch()
    }

    private func performSearch() async {
        state = .loading
        do {
            let response = try await service.search(request)
            let offers = FlightOfferMapper.map(response, request: request)
            allOffers = offers
            state = offers.isEmpty ? .empty : .success(offers)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func tapLearnMore(url: URL) {
        delegate?.didTapLearnMore(url: url)
    }

    func selectFlight(_ offer: FlightOffer) {
        delegate?.didSelectFlight(offer)
    }

    /// Re-sorts the currently-held offers in place — does not re-fetch.
    func applySort(_ option: SortOption) {
        guard case .success = state else { return }
        let sorted = Self.sortedOffers(allOffers, by: option)
        allOffers = sorted
        state = .success(sorted)
    }

    /// A plain, directly-testable function rather than something the View
    /// computes while rendering. Swift's `sorted(by:)` is a stable sort, so
    /// ties keep their original relative order.
    static func sortedOffers(_ offers: [FlightOffer], by option: SortOption) -> [FlightOffer] {
        switch option {
        case .cheapest:
            return offers.sorted { $0.price < $1.price }
        case .fastest:
            return offers.sorted { $0.totalDurationMinutes < $1.totalDurationMinutes }
        }
    }
}

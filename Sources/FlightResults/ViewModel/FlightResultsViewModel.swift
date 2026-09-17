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

    /// Keeps the loading skeleton on screen for at least this long, so a
    /// fast response (e.g. a warm connection) doesn't flash past it.
    /// Defaults to 0 so unit tests stay instant; production wiring passes 2s.
    private let minimumLoadingDurationNanoseconds: UInt64

    /// `FlightResultsView.task` calls `load()` every time the view appears,
    /// including when it's just been re-exposed after a `NavigationStack`
    /// pop (e.g. returning from `WebLinkView`) — not only on first launch.
    /// This guard makes `load()` a one-shot: once a fetch has started, later
    /// calls are no-ops, so navigating away and back never re-fetches or
    /// re-shows the loading state. `retry()` bypasses the guard on purpose,
    /// since it's only ever invoked by an explicit user tap.
    private var hasLoaded = false

    init(
        request: FlightSearchRequest,
        service: FlightSearchServicing,
        minimumLoadingDurationNanoseconds: UInt64 = 0
    ) {
        self.request = request
        self.service = service
        self.minimumLoadingDurationNanoseconds = minimumLoadingDurationNanoseconds
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
            async let response = service.search(request)
            async let minimumDelay: ()? = try? Task.sleep(nanoseconds: minimumLoadingDurationNanoseconds)

            let result = try await response
            _ = await minimumDelay

            let offers = FlightOfferMapper.map(result, request: request)
            allOffers = offers
            state = offers.isEmpty ? .empty : .success(offers)
        } catch {
            state = .error(Self.userFacingMessage(for: error))
        }
    }

    /// `FlightSearchServiceError` already carries user-friendly copy via
    /// `LocalizedError`; anything else (decoding failures, `URLError`, etc.)
    /// gets a generic message instead of leaking a system-level description.
    private static func userFacingMessage(for error: Error) -> String {
        (error as? FlightSearchServiceError)?.errorDescription
            ?? "We couldn't load flight results. Please check your connection and try again."
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

import XCTest
@testable import FlightResults

@MainActor
private final class MockFlightSearchService: FlightSearchServicing {
    var result: Result<FlightSearchResponse, Error> = .failure(TestError())
    private(set) var callCount = 0
    private(set) var lastRequest: FlightSearchRequest?

    func search(_ request: FlightSearchRequest) async throws -> FlightSearchResponse {
        callCount += 1
        lastRequest = request
        return try result.get()
    }
}

@MainActor
private final class MockCoordinatorDelegate: FlightResultsCoordinatorDelegate {
    private(set) var selectedOffer: FlightOffer?
    private(set) var learnMoreURL: URL?

    func didSelectFlight(_ offer: FlightOffer) {
        selectedOffer = offer
    }

    func didTapLearnMore(url: URL) {
        learnMoreURL = url
    }
}

@MainActor
final class FlightResultsViewModelTests: XCTestCase {
    private func makeSUT(
        result: Result<FlightSearchResponse, Error> = .failure(TestError())
    ) -> (viewModel: FlightResultsViewModel, service: MockFlightSearchService, delegate: MockCoordinatorDelegate) {
        let service = MockFlightSearchService()
        service.result = result
        let viewModel = FlightResultsViewModel(request: TestFixtures.request(), service: service)
        let delegate = MockCoordinatorDelegate()
        viewModel.delegate = delegate
        return (viewModel, service, delegate)
    }

    // MARK: initial state

    func test_initialState_isLoading() {
        let (viewModel, _, _) = makeSUT()
        guard case .loading = viewModel.state else {
            return XCTFail("expected .loading, got \(viewModel.state)")
        }
    }

    // MARK: load()

    func test_load_success_withOffers_setsSuccessState() async {
        let group = TestFixtures.rawGroup(flights: [TestFixtures.rawLeg(airline: "ANA")], price: 582)
        let response = FlightSearchResponse(bestFlights: [group], otherFlights: nil)
        let (viewModel, _, _) = makeSUT(result: .success(response))

        await viewModel.load()

        guard case .success(let offers) = viewModel.state else {
            return XCTFail("expected .success, got \(viewModel.state)")
        }
        XCTAssertEqual(offers.count, 1)
        XCTAssertEqual(offers.first?.airline, "ANA")
    }

    func test_load_success_withNoOffers_setsEmptyState() async {
        let response = FlightSearchResponse(bestFlights: [], otherFlights: [])
        let (viewModel, _, _) = makeSUT(result: .success(response))

        await viewModel.load()

        guard case .empty = viewModel.state else {
            return XCTFail("expected .empty, got \(viewModel.state)")
        }
    }

    func test_load_failure_setsErrorStateWithMessage() async {
        let (viewModel, _, _) = makeSUT(result: .failure(TestError("boom")))

        await viewModel.load()

        guard case .error(let message) = viewModel.state else {
            return XCTFail("expected .error, got \(viewModel.state)")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func test_load_calledTwice_onlyFetchesOnce() async {
        let response = FlightSearchResponse(bestFlights: [TestFixtures.rawGroup()], otherFlights: nil)
        let (viewModel, service, _) = makeSUT(result: .success(response))

        await viewModel.load()
        await viewModel.load()

        // Guards against re-fetching (and re-showing the loading skeleton)
        // when `.task` fires again after returning from a pushed screen.
        XCTAssertEqual(service.callCount, 1)
    }

    func test_load_passesRequestThrough() async {
        let request = TestFixtures.request(departureId: "SFO", arrivalId: "NRT")
        let service = MockFlightSearchService()
        service.result = .success(FlightSearchResponse(bestFlights: nil, otherFlights: nil))
        let viewModel = FlightResultsViewModel(request: request, service: service)

        await viewModel.load()

        XCTAssertEqual(service.lastRequest?.departureId, "SFO")
        XCTAssertEqual(service.lastRequest?.arrivalId, "NRT")
    }

    // MARK: retry()

    func test_retry_alwaysRefetches_bypassingTheLoadGuard() async {
        let response = FlightSearchResponse(bestFlights: [TestFixtures.rawGroup()], otherFlights: nil)
        let (viewModel, service, _) = makeSUT(result: .success(response))

        await viewModel.load()
        await viewModel.retry()
        await viewModel.retry()

        XCTAssertEqual(service.callCount, 3)
    }

    func test_retry_afterFailure_canSucceed() async {
        let service = MockFlightSearchService()
        service.result = .failure(TestError())
        let viewModel = FlightResultsViewModel(request: TestFixtures.request(), service: service)

        await viewModel.load()
        guard case .error = viewModel.state else {
            return XCTFail("expected .error before retry")
        }

        service.result = .success(FlightSearchResponse(bestFlights: [TestFixtures.rawGroup()], otherFlights: nil))
        await viewModel.retry()

        guard case .success = viewModel.state else {
            return XCTFail("expected .success after retry, got \(viewModel.state)")
        }
    }

    // MARK: applySort()

    func test_applySort_whenSuccess_reordersOffers() async {
        let cheap = TestFixtures.rawGroup(flights: [TestFixtures.rawLeg(airline: "Cheap")], price: 100)
        let pricey = TestFixtures.rawGroup(flights: [TestFixtures.rawLeg(airline: "Pricey")], price: 900)
        let response = FlightSearchResponse(bestFlights: [pricey, cheap], otherFlights: nil)
        let (viewModel, _, _) = makeSUT(result: .success(response))
        await viewModel.load()

        viewModel.applySort(.cheapest)

        guard case .success(let offers) = viewModel.state else {
            return XCTFail("expected .success, got \(viewModel.state)")
        }
        XCTAssertEqual(offers.map(\.airline), ["Cheap", "Pricey"])
    }

    func test_applySort_whenNotSuccess_isNoOp() {
        let (viewModel, _, _) = makeSUT()
        // state is still .loading — sorting shouldn't crash or change it.
        viewModel.applySort(.cheapest)

        guard case .loading = viewModel.state else {
            return XCTFail("expected .loading to remain unchanged, got \(viewModel.state)")
        }
    }

    // MARK: delegate forwarding

    func test_tapLearnMore_forwardsURLToDelegate() {
        let (viewModel, _, delegate) = makeSUT()
        let url = URL(string: "https://example.com")!

        viewModel.tapLearnMore(url: url)

        XCTAssertEqual(delegate.learnMoreURL, url)
    }

    func test_selectFlight_forwardsOfferToDelegate() {
        let (viewModel, _, delegate) = makeSUT()
        let offer = TestFixtures.offer(id: "selected-offer")

        viewModel.selectFlight(offer)

        XCTAssertEqual(delegate.selectedOffer?.id, "selected-offer")
    }
}

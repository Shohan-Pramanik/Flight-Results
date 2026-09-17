import SwiftUI

@main
struct FlightResultsApp: App {
    @StateObject private var coordinator: FlightResultsCoordinator

    init() {
        let request = FlightSearchRequest(
            departureId: "LAX",
            arrivalId: "HND",
            outboundDate: DateFormatting.apiDate.date(from: "2026-09-30")!,
            currency: "USD"
        )

        // Reads the bundled fixture (a real captured SerpApi response)
        // instead of hitting the network — no live API calls, no key
        // required. Swap back to LiveFlightSearchService once a real key
        // is wired up via Config/Secrets.xcconfig.
//        #if DEBUG
//        let service: FlightSearchServicing = FixtureFlightSearchService()
//        #else
//        let service: FlightSearchServicing = LiveFlightSearchService()
//        #endif

        let service: FlightSearchServicing = LiveFlightSearchService()
        
        let viewModel = FlightResultsViewModel(request: request, service: service)
        _coordinator = StateObject(wrappedValue: FlightResultsCoordinator(viewModel: viewModel))
    }

    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
}

import Foundation

/// Serves the bundled, real captured SerpApi response
/// (Fixtures/lax_hnd_response.json) instead of hitting the network — no
/// live API calls, no API key required. Wired in for DEBUG builds in
/// FlightResultsApp; LiveFlightSearchService remains the Release path.
final class FixtureFlightSearchService: FlightSearchServicing {
    private let fixtureName: String
    private let bundle: Bundle

    init(fixtureName: String = "lax_hnd_response", bundle: Bundle = .main) {
        self.fixtureName = fixtureName
        self.bundle = bundle
    }

    func search(_ request: FlightSearchRequest) async throws -> FlightSearchResponse {
        guard let url = bundle.url(forResource: fixtureName, withExtension: "json", subdirectory: "Fixtures") else {
            throw FlightSearchServiceError.invalidResponse
        }
        let data = try Data(contentsOf: url)

        // Fixture data loads near-instantly, which would make the loading
        // state (and its shimmer) invisible — this stand-in delay mimics a
        // real network round trip so the loading UI is actually reachable.
        try await Task.sleep(nanoseconds: 3_000_000_000)

        return try JSONDecoder().decode(FlightSearchResponse.self, from: data)
    }
}

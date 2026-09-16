import Foundation

/// Dev-only decorator: caches the raw decoded response to disk, keyed by
/// the request parameters, so iterating on UI (and re-running the app)
/// doesn't burn the SerpApi trial quota. Only wired in for `DEBUG` builds
/// (see `FlightResultsApp`) — Release always hits `LiveFlightSearchService`
/// directly.
final class CachingFlightSearchService: FlightSearchServicing {
    private let wrapped: FlightSearchServicing
    private let cacheDirectory: URL
    private let fileManager: FileManager

    init(wrapping wrapped: FlightSearchServicing, fileManager: FileManager = .default) {
        self.wrapped = wrapped
        self.fileManager = fileManager

        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = caches.appendingPathComponent("FlightSearchCache", isDirectory: true)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func search(_ request: FlightSearchRequest) async throws -> FlightSearchResponse {
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey(for: request)).appendingPathExtension("json")

        if let cachedData = try? Data(contentsOf: fileURL),
           let cachedResponse = try? JSONDecoder().decode(FlightSearchResponse.self, from: cachedData) {
            return cachedResponse
        }

        let response = try await wrapped.search(request)

        if let data = try? JSONEncoder().encode(response) {
            try? data.write(to: fileURL, options: .atomic)
        }

        return response
    }

    private func cacheKey(for request: FlightSearchRequest) -> String {
        [
            request.departureId,
            request.arrivalId,
            DateFormatting.apiDate.string(from: request.outboundDate),
            request.currency,
            String(request.type)
        ].joined(separator: "_")
    }
}

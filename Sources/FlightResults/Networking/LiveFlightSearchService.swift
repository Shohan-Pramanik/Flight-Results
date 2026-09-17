import Foundation

enum FlightSearchServiceError: Error, LocalizedError, Equatable {
    case missingAPIKey
    case invalidResponse
    case httpError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing SerpApi API key. Add one to Config/Secrets.xcconfig."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpError(let statusCode):
            return "Request failed with status code \(statusCode)."
        }
    }
}

final class LiveFlightSearchService: FlightSearchServicing {
    private let session: URLSession
    private let apiKeyProvider: () -> String?

    init(
        session: URLSession = .shared,
        apiKeyProvider: @escaping () -> String? = { APIConfig.serpApiKey }
    ) {
        self.session = session
        self.apiKeyProvider = apiKeyProvider
    }

    func search(_ request: FlightSearchRequest) async throws -> FlightSearchResponse {
        guard let apiKey = apiKeyProvider(), !apiKey.isEmpty else {
            throw FlightSearchServiceError.missingAPIKey
        }

        var components = URLComponents(string: "https://serpapi.com/search")!
        components.queryItems = [
            URLQueryItem(name: "engine", value: "google_flights"),
            URLQueryItem(name: "departure_id", value: request.departureId),
            URLQueryItem(name: "arrival_id", value: request.arrivalId),
            URLQueryItem(name: "outbound_date", value: DateFormatting.apiDate.string(from: request.outboundDate)),
            URLQueryItem(name: "type", value: String(request.type)),
            URLQueryItem(name: "currency", value: request.currency),
            URLQueryItem(name: "hl", value: "en"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]

        guard let url = components.url else {
            throw FlightSearchServiceError.invalidResponse
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw FlightSearchServiceError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw FlightSearchServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        return try JSONDecoder().decode(FlightSearchResponse.self, from: data)
    }
}

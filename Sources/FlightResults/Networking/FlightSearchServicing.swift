import Foundation

protocol FlightSearchServicing {
    func search(_ request: FlightSearchRequest) async throws -> FlightSearchResponse
}

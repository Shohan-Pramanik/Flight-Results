import Foundation

/// This screen has no search form — the request is fixed for a single
/// route/date, constructed once at app launch.
struct FlightSearchRequest {
    let departureId: String
    let arrivalId: String
    let outboundDate: Date
    let currency: String
    let type: Int = 2 // one-way, fixed — this screen never does round trip
}

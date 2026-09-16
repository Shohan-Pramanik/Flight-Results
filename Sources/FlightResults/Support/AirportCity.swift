import Foundation

/// The route header shows city names, not IATA codes, per the spec — but
/// that mapping isn't in the SerpApi response for the header (it's derived
/// from the fixed search request). This is a small static lookup for the
/// two airports this task's reference search actually uses; any unknown
/// code falls back to showing the raw code rather than guessing a name.
enum AirportCity {
    private static let names: [String: String] = [
        "LAX": "Los Angeles",
        "HND": "Tokyo"
    ]

    static func name(forCode code: String) -> String {
        names[code] ?? code
    }
}

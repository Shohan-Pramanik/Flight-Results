import Foundation

enum ResultRow: Identifiable {
    case flight(FlightOffer)
    case promo

    var id: String {
        switch self {
        case .flight(let offer): return offer.id
        case .promo: return "promo"
        }
    }
}

enum ResultRowBuilder {
    /// Inserts a single `.promo` row after the second flight offer. If
    /// there aren't more than two offers, there's nothing to sit "between"
    /// — the carousel is simply not shown.
    static func rows(for offers: [FlightOffer]) -> [ResultRow] {
        var rows = offers.map(ResultRow.flight)
        guard rows.count > 2 else { return rows }
        rows.insert(.promo, at: 2)
        return rows
    }
}

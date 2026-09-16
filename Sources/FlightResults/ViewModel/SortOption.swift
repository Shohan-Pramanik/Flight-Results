import Foundation

enum SortOption: Equatable {
    case cheapest // ascending by price
    case fastest  // ascending by totalDurationMinutes
}

extension SortOption {
    var label: String {
        switch self {
        case .cheapest: return "Cheapest"
        case .fastest: return "Fastest"
        }
    }
}

import Foundation

enum FlightOfferFormatting {
    /// `810` minutes -> `"13h 30m"`
    static func duration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(String(format: "%02d", remainingMinutes))m"
    }

    /// `(37400, "BDT")` -> `"BDT 37,400"`
    static func price(_ amount: Int, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? String(amount)
        return "\(currencyCode) \(formatted)"
    }
}

import Foundation

/// SerpApi returns airport-local times as bare `"yyyy-MM-dd HH:mm"` strings
/// with no timezone/offset attached. We parse and later format them all in
/// a single fixed calendar/timezone so a value round-trips to the same
/// wall-clock string regardless of the device's local timezone.
enum DateFormatting {
    static let apiDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    static let apiDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    static let flightTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    /// e.g. "30 Sep 2026"
    static func displayDate(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let day = calendar.component(.day, from: date)

        let monthYearFormatter = DateFormatter()
        monthYearFormatter.dateFormat = "MMM yyyy"
        monthYearFormatter.locale = Locale(identifier: "en_US_POSIX")
        monthYearFormatter.timeZone = TimeZone(identifier: "UTC")

        return "\(day) \(monthYearFormatter.string(from: date))"
    }
}

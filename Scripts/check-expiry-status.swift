// Runnable check for ExpiryStatus, compiled against the real source.
//
//   swiftc InShelf/Models/ExpiryStatus.swift Scripts/check-expiry-status.swift -o /tmp/check && /tmp/check
//
// Lives outside InShelf/ because that folder is file-system-synchronized —
// anything with a .swift extension in there gets compiled into the app.
// Port these cases into a real test target when one exists.

import Foundation

@main
struct ExpiryStatusCheck {

    /// Fixed clock and calendar so the result never depends on when this runs.
    static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    static func expect(
        _ expirationDate: Date?,
        _ expected: ExpiryStatus,
        _ what: String,
        line: Int = #line
    ) {
        let now = date(2026, 8, 18, hour: 12)
        let actual = ExpiryStatus.status(for: expirationDate, asOf: now, calendar: calendar)
        precondition(
            actual == expected,
            "line \(line): \(what) — expected \(expected), got \(actual)"
        )
        print("  ok  \(what)")
    }

    static func main() {
        print("ExpiryStatus — reference now = 2026-08-18 12:00 UTC")

        expect(nil, .none, "no expiration date")

        expect(date(2026, 8, 17), .expired, "yesterday is expired")
        expect(date(2026, 1, 1), .expired, "long past is expired")

        // The reason both sides are normalized to startOfDay: an item expiring
        // today has not expired yet, whatever the current time is.
        expect(date(2026, 8, 18, hour: 0), .expiringSoon, "earlier today is not expired")
        expect(date(2026, 8, 18, hour: 23), .expiringSoon, "later today is not expired")

        expect(date(2026, 8, 19), .expiringSoon, "tomorrow is expiring soon")
        expect(date(2026, 8, 21), .expiringSoon, "exactly 3 days out is expiring soon")
        expect(date(2026, 8, 22), .valid, "4 days out is valid")
        expect(date(2027, 8, 18), .valid, "a year out is valid")

        print("all ExpiryStatus checks passed")
    }
}

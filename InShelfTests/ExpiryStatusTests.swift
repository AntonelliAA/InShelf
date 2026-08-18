import Foundation
import Testing
@testable import InShelf

/// A fixed calendar and clock, so a passing suite never depends on the day it runs.
private let utc: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}()

private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
    utc.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// Reference "now" for every case below: midday on 18 August 2026.
private let now = date(2026, 8, 18, hour: 12)

private func status(of expirationDate: Date?) -> ExpiryStatus {
    ExpiryStatus.status(for: expirationDate, asOf: now, calendar: utc)
}

@Suite("Expiry classification")
struct ExpiryStatusTests {

    @Test("An item without an expiration date never expires")
    func noExpirationDate() {
        #expect(status(of: nil) == .none)
    }

    @Test("A date before today is expired", arguments: [
        date(2026, 8, 17),
        date(2026, 1, 1),
    ])
    func pastDatesAreExpired(expirationDate: Date) {
        #expect(status(of: expirationDate) == .expired)
    }

    /// Why both sides are normalized to the start of their day: an item whose
    /// expiration falls on today has not expired yet, whatever the clock reads.
    /// Comparing raw `Date` values makes this fail for any hour before noon.
    @Test("A date falling today has not expired yet", arguments: [0, 12, 23])
    func todayHasNotExpired(hour: Int) {
        #expect(status(of: date(2026, 8, 18, hour: hour)) == .expiringSoon)
    }

    @Test("A date within the threshold is expiring soon", arguments: [
        date(2026, 8, 19),
        date(2026, 8, 21),  // exactly at the threshold
    ])
    func withinThresholdIsExpiringSoon(expirationDate: Date) {
        #expect(status(of: expirationDate) == .expiringSoon)
    }

    @Test("A date past the threshold is valid", arguments: [
        date(2026, 8, 22),  // one day past the threshold
        date(2027, 8, 18),
    ])
    func pastThresholdIsValid(expirationDate: Date) {
        #expect(status(of: expirationDate) == .valid)
    }

    @Test("The threshold boundary is inclusive")
    func thresholdIsInclusive() {
        let boundary = utc.date(byAdding: .day, value: ExpiryStatus.soonThresholdInDays, to: now)!
        let justPast = utc.date(byAdding: .day, value: ExpiryStatus.soonThresholdInDays + 1, to: now)!

        #expect(status(of: boundary) == .expiringSoon)
        #expect(status(of: justPast) == .valid)
    }
}

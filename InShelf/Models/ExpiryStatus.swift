import Foundation

/// How close an item is to expiring.
///
/// Deliberately Foundation-only and free of SwiftData and SwiftUI so the
/// classification can be compiled and asserted on its own — see
/// `Scripts/check-expiry-status.swift`. Colors live in the view layer.
enum ExpiryStatus: Equatable {
    /// The item has no expiration date.
    case none
    case valid
    case expiringSoon
    case expired

    /// Days before expiration at which an item starts reading as "expiring soon".
    static let soonThresholdInDays = 3

    /// Classifies an expiration date relative to `now`.
    ///
    /// Both dates are normalized to the start of their day, so an item expiring
    /// later today is not already expired.
    static func status(
        for expirationDate: Date?,
        asOf now: Date = Date(),
        calendar: Calendar = .current
    ) -> ExpiryStatus {
        guard let expirationDate else { return .none }

        let today = calendar.startOfDay(for: now)
        let target = calendar.startOfDay(for: expirationDate)

        if target < today { return .expired }

        guard let days = calendar.dateComponents([.day], from: today, to: target).day else {
            return .valid
        }
        return days <= soonThresholdInDays ? .expiringSoon : .valid
    }
}

import Foundation

/// The expiry lens applied to the stock list.
enum StockFilter: String, CaseIterable, Identifiable {
    case all
    case expiringSoon
    case expired

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .expiringSoon: return "Expiring soon"
        case .expired: return "Expired"
        }
    }

    var systemImage: String {
        switch self {
        case .all: return "tray.full"
        case .expiringSoon: return "clock"
        case .expired: return "exclamationmark.triangle"
        }
    }
}

extension Collection where Element == StockItem {

    /// Case- and diacritic-insensitive name search. An empty query matches everything,
    /// so callers do not need to special-case "no search".
    func matching(query: String) -> [StockItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return Array(self) }
        return filter { $0.name.localizedStandardContains(trimmed) }
    }

    func matching(filter: StockFilter, asOf now: Date = Date()) -> [StockItem] {
        switch filter {
        case .all:
            return Array(self)
        case .expiringSoon:
            return self.filter { $0.expiryStatus(asOf: now) == .expiringSoon }
        case .expired:
            return self.filter { $0.expiryStatus(asOf: now) == .expired }
        }
    }

    /// Soonest expiration first. Undated items sort last, newest among themselves.
    func sortedByExpiry() -> [StockItem] {
        sorted { a, b in
            switch (a.expirationDate, b.expirationDate) {
            case let (lhs?, rhs?):
                return lhs < rhs
            case (nil, _?):
                return false
            case (_?, nil):
                return true
            default:
                return a.createdAt > b.createdAt
            }
        }
    }
}

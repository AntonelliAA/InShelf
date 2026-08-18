import Foundation
import Testing
@testable import InShelf

@Suite("Searching and filtering stock")
struct StockFilterTests {

    // MARK: Search

    @Test("An empty query matches everything, so callers need no special case")
    func emptyQueryMatchesAll() {
        let items = [makeItem(name: "Milk"), makeItem(name: "Bread")]
        #expect(items.matching(query: "").count == 2)
        #expect(items.matching(query: "   ").count == 2)
    }

    @Test("Search ignores case")
    func searchIgnoresCase() {
        let items = [makeItem(name: "Milk")]
        #expect(items.matching(query: "milk").count == 1)
        #expect(items.matching(query: "MILK").count == 1)
    }

    /// Typing without accents is how people actually search on a phone keyboard.
    @Test("Search ignores diacritics")
    func searchIgnoresDiacritics() {
        let items = [makeItem(name: "Açúcar")]
        #expect(items.matching(query: "acucar").count == 1)
        #expect(items.matching(query: "AÇÚCAR").count == 1)
    }

    @Test("Search matches partway through a name")
    func searchMatchesSubstring() {
        let items = [makeItem(name: "Whole milk")]
        #expect(items.matching(query: "milk").count == 1)
    }

    @Test("A query matching nothing returns nothing")
    func searchCanReturnEmpty() {
        #expect([makeItem(name: "Milk")].matching(query: "bread").isEmpty)
    }

    // MARK: Filter

    @Test("Each filter selects only its own expiry status")
    func filtersByExpiryStatus() {
        let now = Date()
        let calendar = Calendar.current
        let expired = makeItem(name: "Expired", expirationDate: calendar.date(byAdding: .day, value: -1, to: now))
        let soon = makeItem(name: "Soon", expirationDate: calendar.date(byAdding: .day, value: 1, to: now))
        let valid = makeItem(name: "Valid", expirationDate: calendar.date(byAdding: .day, value: 30, to: now))
        let undated = makeItem(name: "Undated")
        let items = [expired, soon, valid, undated]

        #expect(items.matching(filter: .all, asOf: now).count == 4)
        #expect(items.matching(filter: .expired, asOf: now).map(\.name) == ["Expired"])
        #expect(items.matching(filter: .expiringSoon, asOf: now).map(\.name) == ["Soon"])
    }

    // MARK: Sorting

    @Test("Sorting puts the soonest expiration first")
    func sortsSoonestFirst() {
        let now = Date()
        let calendar = Calendar.current
        let later = makeItem(name: "Later", expirationDate: calendar.date(byAdding: .day, value: 10, to: now))
        let sooner = makeItem(name: "Sooner", expirationDate: calendar.date(byAdding: .day, value: 2, to: now))

        #expect([later, sooner].sortedByExpiry().map(\.name) == ["Sooner", "Later"])
    }

    /// An item with no date is not urgent, so it must never outrank one that has a date.
    @Test("Sorting puts undated items last")
    func sortsUndatedLast() {
        let dated = makeItem(name: "Dated", expirationDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()))
        let undated = makeItem(name: "Undated")

        #expect([undated, dated].sortedByExpiry().map(\.name) == ["Dated", "Undated"])
        #expect([dated, undated].sortedByExpiry().map(\.name) == ["Dated", "Undated"])
    }
}

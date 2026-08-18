import Foundation
import Testing
@testable import InShelf

@Suite("Stock item derived properties")
struct StockItemTests {

    @Test("Reading state decodes the stored column")
    func readsStoredState() {
        #expect(makeItem(state: .inStock).state == .inStock)
        #expect(makeItem(state: .toBuy).state == .toBuy)
    }

    /// The stored column is a plain String, so a value written by an older
    /// build or a bad migration must degrade rather than crash.
    @Test("An unrecognised stored value falls back to toBuy")
    func unrecognisedStateFallsBack() {
        #expect(makeItemWithRawState("something else").state == .toBuy)
    }

    @Test("Writing state updates the stored column")
    func writesStoredState() {
        let item = makeItem(state: .toBuy)
        item.state = .inStock
        #expect(item.stateRaw == "inStock")
    }

    @Test("An item with no expiration date reports no expiry status")
    func noExpirationDate() {
        #expect(makeItem().expiryStatus() == .none)
    }

    @Test("An item carries its expiration date into the classification")
    func classifiesItsOwnExpirationDate() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        #expect(makeItem(expirationDate: yesterday).expiryStatus() == .expired)
    }
}

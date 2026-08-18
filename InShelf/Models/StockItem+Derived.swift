import Foundation

// Computed properties live in an extension so the @Model macro does not try to
// persist them. `stateRaw` stays the stored column; nothing outside this file
// should touch it.
extension StockItem {
    var state: ItemPurchaseState {
        get { ItemPurchaseState(rawValue: stateRaw) ?? .toBuy }
        set { stateRaw = newValue.rawValue }
    }

    func expiryStatus(asOf now: Date = Date()) -> ExpiryStatus {
        ExpiryStatus.status(for: expirationDate, asOf: now)
    }
}

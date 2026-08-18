import Foundation
@testable import InShelf

/// Builds a `StockItem` with everything defaulted, so each test names only the
/// one or two fields it actually cares about.
func makeItem(
    name: String = "Milk",
    quantity: Int = 1,
    expirationDate: Date? = nil,
    state: ItemPurchaseState = .toBuy
) -> StockItem {
    StockItem(
        name: name,
        iconRaw: ItemIcon.avocado.rawValue,
        quantity: quantity,
        unitRaw: UnitType.units.rawValue,
        notes: "",
        expirationDate: expirationDate,
        alwaysInList: false,
        recipesCount: 0,
        stateRaw: state.rawValue
    )
}

/// Escape hatch for the one case the typed factory cannot express: a stored
/// state string that no longer maps to a known case.
func makeItemWithRawState(_ stateRaw: String) -> StockItem {
    StockItem(
        name: "Milk",
        iconRaw: ItemIcon.avocado.rawValue,
        quantity: 1,
        unitRaw: UnitType.units.rawValue,
        notes: "",
        expirationDate: nil,
        alwaysInList: false,
        recipesCount: 0,
        stateRaw: stateRaw
    )
}

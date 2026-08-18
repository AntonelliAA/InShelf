import Foundation

/// Whether an item is already owned or still needs to be bought.
enum ItemPurchaseState: String, CaseIterable, Codable {
    case toBuy
    case inStock

    var title: String {
        switch self {
        case .toBuy: return "To buy"
        case .inStock: return "In Stock"
        }
    }
}

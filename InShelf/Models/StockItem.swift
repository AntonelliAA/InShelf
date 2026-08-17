import Foundation
import SwiftData

@Model
final class StockItem {
    var name: String
    var iconRaw: String
    var quantity: Int
    var unitRaw: String
    var notes: String
    var expirationDate: Date?
    var alwaysInList: Bool
    var recipesCount: Int
    var stateRaw: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        iconRaw: String,
        quantity: Int,
        unitRaw: String,
        notes: String,
        expirationDate: Date?,
        alwaysInList: Bool,
        recipesCount: Int,
        stateRaw: String
    ) {
        self.name = name
        self.iconRaw = iconRaw
        self.quantity = quantity
        self.unitRaw = unitRaw
        self.notes = notes
        self.expirationDate = expirationDate
        self.alwaysInList = alwaysInList
        self.recipesCount = recipesCount
        self.stateRaw = stateRaw
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

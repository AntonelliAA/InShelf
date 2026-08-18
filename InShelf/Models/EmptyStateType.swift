import Foundation

enum EmptyStateType {
    case stock
    case item
    case shoppingList

    var imageName: String {
        switch self {
        case .stock:
            return "EmptyStock"
        case .item:
            return "EmptyItem"
        case .shoppingList:
            return "EmptyItem"
        }
    }

    var title: String {
        switch self {
        case .stock:
            return "You haven't added any product yet!"
        case .item:
            return "You haven't added any Items yet!"
        case .shoppingList:
            return "Your shopping list is empty!"
        }
    }

    var subtitle: String {
        switch self {
        case .stock:
            return "Create a product and it will appear here."
        case .item:
            return "Create an Item and it will appear here."
        case .shoppingList:
            return "Add something to buy and it will appear here."
        }
    }

    var actionTitle: String {
        switch self {
        case .stock, .item:
            return "Create item"
        case .shoppingList:
            return "Add to list"
        }
    }
}

import Foundation

enum EmptyStateType {
    case stock
    case item

    var imageName: String {
        switch self {
        case .stock:
            return "EmptyStock"
        case .item:
            return "EmptyItem"
        }
    }

    var title: String {
        switch self {
        case .stock:
            return "You haven't added any product yet!"
        case .item:
            return "You haven't added any Items yet!"
        }
    }

    var subtitle: String {
        switch self {
        case .stock:
            return "Create a product and it will appear here."
        case .item:
            return "Create an Item and it will appear here."
        }
    }
}

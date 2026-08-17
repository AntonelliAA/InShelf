//
//  ItemBarType.swift
//  InShelf
//
//  Created by Anthony Antonelli Andrade on 08/08/25.
//

import Foundation

enum ItemBarType: Equatable {
    case normal(name: String, location: String, quantity: Int, expiry: String)
    case warning(name: String, location: String, quantity: Int, expiry: String, expiredCount: Int)
    case addOnly(name: String)
    case addRemove(name: String, quantity: Int)
    case simple(name: String)

    var isWarning: Bool {
        if case .warning = self { return true }
        return false
    }
}

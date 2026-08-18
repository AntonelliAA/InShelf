//
//  Stock.swift
//  InShelf
//
//  Created by Anthony Antonelli Andrade on 11/08/25.
//

import SwiftUI
import SwiftData

struct Stock: View {
    @Query(sort: \StockItem.createdAt, order: .reverse) private var allItems: [StockItem]
    
    private var inStockItems: [StockItem] {
        allItems.filter { $0.state == .inStock }
    }

    private var expiredItems: [StockItem] {
        inStockItems.filter { $0.expiryStatus() == .expired }
    }

    /// Everything still edible, soonest expiration first, undated items last.
    private var validItems: [StockItem] {
        inStockItems
            .filter { $0.expiryStatus() != .expired }
            .sorted { a, b in
                switch (a.expirationDate, b.expirationDate) {
                case let (da?, db?):
                    return da < db
                case (nil, _?):
                    return false
                case (_?, nil):
                    return true
                default:
                    return a.createdAt > b.createdAt
                }
            }
    }

    var body: some View {
        ZStack {
            
            Color(.backgroundPrimary).ignoresSafeArea()
            
            if inStockItems.isEmpty {
                VStack {
                    EmptyStateView(type: .stock) { }
                        .padding(.horizontal)
                }
            } else {
                List {
                    if !expiredItems.isEmpty {
                        ItemBar(
                            icon: .warningIconFallback,
                            type: .warning(
                                name: "Expired items",
                                location: "Check and discard",
                                quantity: expiredItems.reduce(0) { $0 + $1.quantity },
                                expiry: "Expired",
                                expiredCount: expiredItems.count
                            ),
                            expiry: .expired
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.backgroundPrimary))
                    }
                    
                    ForEach(validItems) { item in
                        ItemBar(
                            icon: ItemIcon(rawValue: item.iconRaw) ?? .avocado,
                            type: .normal(
                                name: item.name,
                                location: item.state.title,
                                quantity: item.quantity,
                                expiry: item.expirationDate.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "—"
                            ),
                            expiry: item.expiryStatus()
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.backgroundPrimary))
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("My Stock")
        
        
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
            }
        }
    }
}

private extension ItemIcon {
    // Fallback icon for the expired summary row
    static var warningIconFallback: ItemIcon { .bento }
}

#Preview {
    TabBar().preferredColorScheme(.dark)
}

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
        allItems.filter { $0.quantity > 0 || $0.stateRaw == "inStock" }
    }

    private var nowStart: Date { Calendar.current.startOfDay(for: Date()) }
    
    private var expiredItems: [StockItem] {
        inStockItems.filter { item in
            if let d = item.expirationDate { return Calendar.current.startOfDay(for: d) < nowStart }
            return false
        }
    }
    
    private var validItems: [StockItem] {
        inStockItems.filter { item in
            guard let d = item.expirationDate else { return true }
            return Calendar.current.startOfDay(for: d) >= nowStart
        }
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
    
    private func expiryColor(for date: Date?) -> Color {
        guard let date else { return .greenPrimary }
        let target = Calendar.current.startOfDay(for: date)
        if target < nowStart { return .redSecondary }
        if let days = Calendar.current.dateComponents([.day], from: nowStart, to: target).day, days <= 3 {
            return Color(.orangePrimary)
        }
        return .greenPrimary
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
                            expiryColor: .redSecondary
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.backgroundPrimary))
                    }
                    
                    ForEach(validItems) { item in
                        ItemBar(
                            icon: ItemIcon(rawValue: item.iconRaw) ?? .avocado,
                            type: .normal(
                                name: item.name,
                                location: "In Stock",
                                quantity: item.quantity,
                                expiry: item.expirationDate.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "—"
                            ),
                            expiryColor: expiryColor(for: item.expirationDate)
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

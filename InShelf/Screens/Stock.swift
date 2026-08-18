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

    @State private var searchText = ""
    @State private var filter: StockFilter = .all
    @State private var isAddingItem = false

    /// Everything owned, before search or filter — what decides "is this screen empty".
    private var stockedItems: [StockItem] {
        allItems.filter { $0.state == .inStock }
    }

    private var searchedItems: [StockItem] {
        stockedItems.matching(query: searchText)
    }

    private var expiredItems: [StockItem] {
        searchedItems.matching(filter: .expired)
    }

    /// Under `.all` the expired items are represented by the summary banner rather
    /// than individual rows, so they are excluded here to avoid showing both.
    private var visibleItems: [StockItem] {
        switch filter {
        case .all:
            return searchedItems.filter { $0.expiryStatus() != .expired }.sortedByExpiry()
        case .expiringSoon, .expired:
            return searchedItems.matching(filter: filter).sortedByExpiry()
        }
    }

    private var showsExpiredBanner: Bool {
        filter == .all && !expiredItems.isEmpty
    }

    var body: some View {
        ZStack {
            Color(.backgroundPrimary).ignoresSafeArea()

            if stockedItems.isEmpty {
                EmptyStateView(type: .stock) { isAddingItem = true }
                    .padding(.horizontal)
            } else {
                List {
                    if showsExpiredBanner {
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
                        .contentShape(Rectangle())
                        .onTapGesture { filter = .expired }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.backgroundPrimary))
                    }

                    ForEach(visibleItems) { item in
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
                .searchable(text: $searchText, prompt: "Search your stock")
                .overlay {
                    if visibleItems.isEmpty && !showsExpiredBanner {
                        emptyResults
                    }
                }
            }
        }
        .navigationTitle("My Stock")
        .navigationDestination(isPresented: $isAddingItem) { Item() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Filter", selection: $filter) {
                        ForEach(StockFilter.allCases) { option in
                            Label(option.title, systemImage: option.systemImage).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: filter == .all
                          ? "line.3.horizontal.decrease"
                          : "line.3.horizontal.decrease.circle.fill")
                }
            }
        }
    }

    @ViewBuilder
    private var emptyResults: some View {
        if searchText.isEmpty {
            ContentUnavailableView(
                "Nothing \(filter.title.lowercased())",
                systemImage: filter.systemImage,
                description: Text("No items match this filter.")
            )
        } else {
            ContentUnavailableView.search(text: searchText)
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

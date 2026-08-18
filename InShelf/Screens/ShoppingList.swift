import SwiftUI
import SwiftData

struct ShoppingList: View {
    @Query(sort: \StockItem.createdAt, order: .reverse) private var allItems: [StockItem]
    @Environment(\.modelContext) private var modelContext

    @State private var searchText = ""
    @State private var selectedItem: StockItem?
    @State private var isAddingItem = false

    private var toBuyItems: [StockItem] {
        allItems.filter { $0.state == .toBuy }.matching(query: searchText)
    }

    var body: some View {
        ZStack {
            Color(.backgroundPrimary).ignoresSafeArea()

            if toBuyItems.isEmpty {
                EmptyStateView(type: .shoppingList) { isAddingItem = true }
                    .padding(.horizontal)
            } else {
                List {
                    ForEach(toBuyItems) { item in
                        ItemBar(
                            icon: ItemIcon(rawValue: item.iconRaw) ?? .avocado,
                            type: .addRemove(name: item.name, quantity: item.quantity),
                            onDecrement: { adjust(item, by: -1) },
                            onIncrement: { adjust(item, by: 1) }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture { selectedItem = item }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.backgroundPrimary))
                        .swipeActions(edge: .leading) {
                            Button {
                                moveToStock(item)
                            } label: {
                                Label("In stock", systemImage: "checkmark")
                            }
                            .tint(Color(.greenPrimary))
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search your list")
            }
        }
        .navigationTitle("Shopping List")
        .navigationDestination(item: $selectedItem) { Item(item: $0) }
        .navigationDestination(isPresented: $isAddingItem) { Item() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { isAddingItem = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private func adjust(_ item: StockItem, by delta: Int) {
        item.quantity = max(0, item.quantity + delta)
        item.updatedAt = Date()
    }

    /// Checking an item off is the one action that connects the two tabs:
    /// it leaves this list and appears in My Stock.
    private func moveToStock(_ item: StockItem) {
        item.state = .inStock
        item.updatedAt = Date()
    }
}

#Preview {
    TabBar().preferredColorScheme(.dark)
}

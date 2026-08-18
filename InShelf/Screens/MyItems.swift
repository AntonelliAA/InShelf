import SwiftUI
import SwiftData

struct MyItems: View {
    @Query(sort: \StockItem.createdAt, order: .reverse) private var items: [StockItem]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedItem: StockItem? = nil
    
    var body: some View {
        ZStack {
            
            Color(.backgroundPrimary).ignoresSafeArea()
            
            if items.isEmpty {
                VStack {
                    EmptyStateView(type: .item) { }
                        .padding(.horizontal)
                }
            } else {
                List {
                    ForEach(items) { item in
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
                        .contentShape(Rectangle())
                        .onTapGesture { selectedItem = item }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.backgroundPrimary))
                    }
                    .onDelete { indexSet in
                        indexSet.map { items[$0] }.forEach(modelContext.delete)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("My Items")
        
        .navigationDestination(item: $selectedItem) { item in
            Item(item: item)
        }
        
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    Item()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    TabBar().preferredColorScheme(.dark)
}

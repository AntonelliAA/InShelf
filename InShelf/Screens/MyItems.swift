import SwiftUI
import SwiftData

struct MyItems: View {
    @Query(sort: \StockItem.createdAt, order: .reverse) private var items: [StockItem]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedItem: StockItem? = nil
    
    private func expiryColor(for date: Date?) -> Color {
        guard let date else { return .greenPrimary }
        let now = Calendar.current.startOfDay(for: Date())
        let target = Calendar.current.startOfDay(for: date)
        if target < now { return .redSecondary }
        if let days = Calendar.current.dateComponents([.day], from: now, to: target).day, days <= 3 {
            return Color(.orangePrimary)
        }
        return .greenPrimary
    }
    
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
                                location: item.stateRaw == "inStock" ? "In Stock" : "To buy",
                                quantity: item.quantity,
                                expiry: item.expirationDate.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "—"
                            ),
                            expiryColor: expiryColor(for: item.expirationDate)
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

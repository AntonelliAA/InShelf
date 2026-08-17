import SwiftUI
import SwiftData

@main
struct InShelfApp: App {
    var body: some Scene {
        WindowGroup {
            TabBar()
        }
        .modelContainer(for: [StockItem.self])
    }
}

#Preview {
    TabBar()
}

import SwiftUI

struct TabBar: View {
    var body: some View {
        
        TabView {
            
            Tab("Recipes", systemImage: "list.bullet.clipboard") {
                NavigationStack {
                    ComingSoon()
                }
            }
            
            Tab("List", systemImage: "basket") {
                NavigationStack {
                    ShoppingList()
                }
            }
            
            Tab("Create", systemImage: "plus.circle.fill") {
                Create()
            }
            
            Tab("Stock", systemImage: "shippingbox") {
                NavigationStack {
                    Stock()
                }
            }
            
            Tab("Profile", systemImage: "person") {
                NavigationStack {
                    ComingSoon()
                }
            }
            
        }
        .tint(Color(.redPrimary))
        
    }
}

#Preview {
    TabBar().preferredColorScheme(.dark)
}

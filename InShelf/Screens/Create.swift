import SwiftUI

struct Create: View {
    var body: some View {
        
        NavigationStack {
            ZStack {
                Color(.backgroundPrimary).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        FeaturedCardView()
                        
                        HStack(spacing: 8) {
                            NavigationLink {
                                MyItems()
                            } label: {
                                MenuCardView(imageName: "stock_background", title: "My Items", subtitle: "Manage your items")
                            }
                            
                            MenuCardView(imageName: "recipes_background", title: "My Recipes", subtitle: "Manage your recipes")
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Creations")
            .toolbarBackground(.backgroundPrimary, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    TabBar()
        .preferredColorScheme(.dark)
}

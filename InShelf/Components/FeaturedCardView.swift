import SwiftUI

struct FeaturedCardView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("featured_background")
            VStack(alignment: .leading) {
                Text("Search new Recipes")
                    .font(.headline)
                Text("Add new recipes to your recipe book")
                    .font(.caption)
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.backgroundSecondary)
        }
        .frame(width: 361)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    Create().preferredColorScheme(.dark)
}

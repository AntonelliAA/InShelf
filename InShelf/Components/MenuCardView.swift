import SwiftUI

struct MenuCardView: View {
    let imageName: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Image(imageName)
                .resizable()
                .scaledToFit()
            HStack(alignment: .center, spacing: 4) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.labelSecondary)
                        .lineLimit(1)
                }
                
                Spacer()

                VStack(alignment: .leading){
                    Image(systemName: "pencil")
                        .foregroundStyle(.redPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.labelPrimary)
            .padding(.vertical, 4.0)
            .padding(.horizontal, 8.0)
                        
            .background(.backgroundSecondary)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16,
                    topTrailingRadius: 0,
                )
            )
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MenuCardView(imageName: "stock_background", title: "My Items", subtitle: "Manage your items").preferredColorScheme(.dark)
}

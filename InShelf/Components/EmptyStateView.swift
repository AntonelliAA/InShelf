import SwiftUI

struct EmptyStateView: View {
    
    let type: EmptyStateType
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 8) {
                
                Image(type.imageName)
                    .resizable()
                    .frame(width: 92, height: 72)
                
                VStack(spacing: 16) {
                    Text(type.title)
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(.labelPrimary)
                    
                    Text(type.subtitle)
                        .foregroundStyle(.labelSecondary)
                }
                
            }

            Button(type.actionTitle, action: action)
                .buttonStyle(.borderedProminent)
                .tint(Color(.redPrimary))
        }
    }
}

#Preview {
    EmptyStateView(type: .shoppingList, action: {})
}

#Preview("Light") {
    EmptyStateView(type: .stock, action: {}).preferredColorScheme(.light)
}

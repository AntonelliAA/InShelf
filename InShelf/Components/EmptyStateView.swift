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
            
        }
    }
}

#Preview {
    EmptyStateView(type: .stock, action: {})
}

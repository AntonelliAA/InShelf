//
//  SwiftUIView.swift
//  InShelf
//
//  Created by Anthony Antonelli Andrade on 08/08/25.
//

import SwiftUI

struct ItemBar: View {
    var icon: ItemIcon
    var type: ItemBarType
    var expiry: ExpiryStatus = .none
    /// Only meaningful for `.addRemove`. Absent closures render the controls inert.
    var onDecrement: (() -> Void)?
    var onIncrement: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                icon.image
                    .resizable()
                    .frame(width: 32, height: 32)
                
                switch type {
                case .normal(let name, let location, let quantity, let expiry),
                     .warning(let name, let location, let quantity, let expiry, _):
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name).font(.headline)
                        Text(location).font(.subheadline).foregroundStyle(.labelSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(quantity)")
                            .font(.headline)
                        Text(expiry)
                            .font(.subheadline)
                            .foregroundStyle(self.expiry.color)
                        
                    }
                    
                case .addOnly(let name):
                    Text(name).font(.headline)
                    Spacer()
                    Image(systemName: "plus").foregroundStyle(.greenPrimary)

                case .addRemove(let name, let quantity):
                    Text(name).font(.headline)
                    Spacer()
                    HStack(spacing: 16) {
                        Button { onDecrement?() } label: {
                            Image(systemName: "minus").foregroundStyle(.redSecondary)
                        }
                        .disabled(quantity == 0)
                        Text("\(quantity)").frame(minWidth: 24)
                        Button { onIncrement?() } label: {
                            Image(systemName: "plus").foregroundStyle(.greenPrimary)
                        }
                    }
                    // Without this the row's own tap target swallows both buttons.
                    .buttonStyle(.borderless)

                case .simple(let name):
                    Text(name).font(.headline)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(.backgroundSecondary)
            .foregroundColor(.labelPrimary)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: type.isWarning ? 0 : 16,
                    bottomTrailingRadius: type.isWarning ? 0 : 16,
                    topTrailingRadius: 16,
                )
            )
            
            if case .warning(_, _, _, _, let expiredCount) = type {
                Text("^[\(expiredCount) item](inflect: true) expired")
                    .frame(maxWidth: .infinity, minHeight: 21)
                    .background(.redSecondary)
                    .foregroundColor(.labelPrimary)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 16,
                            bottomTrailingRadius: 16,
                            topTrailingRadius: 0,
                        )
                    )
            }
        }
    }
}

extension ExpiryStatus {
    var color: Color {
        switch self {
        case .none, .valid: return .greenPrimary
        case .expiringSoon: return Color(.orangePrimary)
        case .expired: return .redSecondary
        }
    }
}

#Preview {
    ItemBarGallery().preferredColorScheme(.dark)
}

#Preview("Light") {
    ItemBarGallery().preferredColorScheme(.light)
}

private struct ItemBarGallery: View {
    var body: some View {
        VStack(spacing: 16) {
            ItemBar(icon: .bento, type: .normal(name: "Item", location: "Location", quantity: 3, expiry: "Aug 21"), expiry: .expiringSoon)
            ItemBar(icon: .bento, type: .normal(name: "Item", location: "Location", quantity: 3, expiry: "Sep 30"), expiry: .valid)
            ItemBar(icon: .bento, type: .warning(name: "Item", location: "Location", quantity: 3, expiry: "Expired", expiredCount: 1), expiry: .expired)
            ItemBar(icon: .bento, type: .addOnly(name: "Item"))
            ItemBar(icon: .bento, type: .addRemove(name: "Item", quantity: 1))
            ItemBar(icon: .bento, type: .simple(name: "Item"))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.backgroundPrimary))
    }
}

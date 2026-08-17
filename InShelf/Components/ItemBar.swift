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
    var expiryColor: Color? = nil
    
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
                        Text(name).font(.headline).foregroundColor(.white)
                        Text(location).font(.subheadline).foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(quantity)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(expiry)
                            .font(.subheadline)
                            .foregroundStyle(expiryColor ?? .redSecondary)
                        
                    }
                    
                case .addOnly(let name):
                    Text(name).font(.headline).foregroundColor(.white)
                    Spacer()
                    Image(systemName: "plus").foregroundColor(.greenPrimary)
                    
                case .addRemove(let name, let quantity):
                    Text(name).font(.headline).foregroundColor(.white)
                    Spacer()
                    HStack {
                        Image(systemName: "minus").foregroundColor(Color("RedSecondary"))
                        Text("\(quantity)").foregroundColor(.white)
                        Image(systemName: "plus").foregroundColor(.greenPrimary)
                    }
                    
                case .simple(let name):
                    Text(name).font(.headline).foregroundColor(.labelPrimary)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .frame(width: 361, height: 72)
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
                Text("\(expiredCount) expired items")
                    .frame(maxWidth: 361, maxHeight: 21)
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

#Preview {
    VStack(spacing: 16) {
        ItemBar(icon: .bento, type: .normal(name: "Item", location: "Location", quantity: 3, expiry: "Expiry"))
        ItemBar(icon: .bento, type: .warning(name: "Item", location: "Location", quantity: 3, expiry: "Expiry", expiredCount: 2))
        ItemBar(icon: .bento, type: .addOnly(name: "Item"))
        ItemBar(icon: .bento, type: .addRemove(name: "Item", quantity: 1))
        ItemBar(icon: .bento, type: .simple(name: "Item"))
    }
        .preferredColorScheme(.dark)
}

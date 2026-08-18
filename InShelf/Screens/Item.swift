//
//  Item.swift
//  InShelf
//
//  Created by Anthony Antonelli Andrade on 12/08/25.
//

import SwiftUI

enum UnitType: String, CaseIterable {
    case units
    case kg
    case g
    
    var title: String {
        switch self {
        case .units: return "Units"
        case .kg: return "Kg"
        case .g: return "Grams"
        }
    }
}

struct Item: View {
    var item: StockItem? = nil

    @State private var expirationDate = Date()
    @State private var hasExpiration = false
    @State private var alwaysInList = false
    @State private var recipesCount = 0
    @State private var quantity = 0
    @State private var description = ""
    @State private var purchaseState: ItemPurchaseState = .toBuy
    @State private var title: String = ""
    @State private var selectedIcon: ItemIcon = .avocado
    @FocusState private var isTitleFocused: Bool
    @State private var showIconPicker: Bool = false
    @State private var unit: UnitType = .units
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var didLoadFromItem = false
    @State private var showValidationAlert = false

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isNameValid: Bool { !trimmedTitle.isEmpty }
    
    var body: some View {
        ZStack {
            Color(.backgroundPrimary).ignoresSafeArea()
            ScrollView{
                VStack{
                    HStack{
                        selectedIcon.image
                            .onTapGesture { showIconPicker = true }
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.redSecondary)
                            .onTapGesture { showIconPicker = true }
                        TextField("Item name", text: $title)
                            .font(.title)
                            .bold()
                            .focused($isTitleFocused)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(false)
                        Spacer()
                        Image(systemName: "pencil")
                            .foregroundStyle(.redSecondary)
                            .font(.title2)
                            .bold()
                            .onTapGesture { isTitleFocused = true }
                    }
                    .padding([.top, .leading, .trailing],16)
                    .sheet(isPresented: $showIconPicker) {
                        IconPickerView(selectedIcon: $selectedIcon)
                            .presentationDetents([.medium, .large])
                            .background(Color(.backgroundPrimary).ignoresSafeArea())
                    }
                    HStack(alignment: .center) {
                        Button {
                            purchaseState = .toBuy
                        } label: {
                            VStack{
                                Image(systemName: "plus")
                                    .foregroundStyle(.redSecondary)
                                Text("To buy")
                            }
                            .font(.title2)
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(purchaseState == .toBuy ? Color(.redSecondary) : .clear, lineWidth: 2)
                            )
                            .opacity(purchaseState == .toBuy ? 0.5 : 1)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button {
                            purchaseState = .inStock
                        } label: {
                            VStack{
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.redSecondary)
                                Text("In Stock")
                            }
                            .font(.title2)
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(purchaseState == .inStock ? Color(.greenPrimary) : .clear, lineWidth: 2)
                            )
                            .opacity(purchaseState == .inStock ? 0.5 : 1.0)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding([.top, .leading, .trailing], 16.0)
                    VStack(alignment: .leading) {
                        Text("Quantity")
                            .font(.title2)
                            .foregroundStyle(.labelSecondary)
                        HStack{
                            Menu {
                                ForEach(UnitType.allCases, id: \.self) { option in
                                    Button {
                                        unit = option
                                    } label: {
                                        HStack {
                                            Text(option.title)
                                            if unit == option { Image(systemName: "checkmark") }
                                        }
                                    }
                                }
                            } label: {
                                HStack{
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(.redSecondary)
                                    Text(unit.title)
                                        .foregroundStyle(.labelPrimary)
                                }
                            }
                            Spacer()
                            HStack{
                                Button {
                                    if quantity > 0 { quantity -= 1 }
                                } label: {
                                    Image(systemName: "minus")
                                        .foregroundStyle(.redSecondary)
                                }
                                Text("\(quantity)")
                                    .font(.callout)
                                    .foregroundStyle(.labelPrimary)
                                    .frame(minWidth: 24)
                                Button {
                                    quantity += 1
                                } label: {
                                    Image(systemName: "plus")
                                        .foregroundStyle(.greenPrimary)
                                }
                            }
                        }
                        .padding(.horizontal, 12.0)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius:16)
                                .foregroundStyle(.backgroundSecondary)
                        )
                    }
                    .padding([.top, .leading, .trailing], 16.0)
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.title2)
                            .foregroundStyle(.labelSecondary)
                        HStack{
                            TextField("", text: $description, prompt: Text("#InShelf Tracker").foregroundStyle(.redSecondary))
                                .font(.body)
                                .foregroundStyle(.labelPrimary)
                                .textInputAutocapitalization(.sentences)
                                .disableAutocorrection(false)
                        }
                        .padding(.horizontal, 12.0)
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius:16)
                                .foregroundStyle(.backgroundSecondary)
                        )
                    }
                    .padding([.top, .leading, .trailing], 16.0)
                    VStack(alignment: .leading) {
                        Text("Misc")
                            .font(.title2)
                            .foregroundStyle(.labelSecondary)
                        HStack{
                            HStack{
                                Image(systemName: "trash.slash.circle")
                                    .foregroundStyle(.redSecondary)
                                Text("Expiration")
                            }
                            Spacer()
                            if hasExpiration {
                                DatePicker(
                                    "",
                                    selection: $expirationDate,
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .tint(Color(.redSecondary))
                            }
                            Toggle("", isOn: $hasExpiration)
                                .labelsHidden()
                                .tint(Color(.redSecondary))
                        }
                        .padding(.horizontal, 12.0)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius:16)
                                .foregroundStyle(.backgroundSecondary)
                        )
                        HStack{
                            HStack{
                                Image(systemName: "arrow.uturn.backward.circle")
                                    .foregroundStyle(.redSecondary)
                                Text("Always in list")
                            }
                            Spacer()
                            Toggle("", isOn: $alwaysInList)
                                .labelsHidden()
                                .tint(Color(.redSecondary))
                        }
                        .padding(.horizontal, 12.0)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius:16)
                                .foregroundStyle(.backgroundSecondary)
                        )
                        HStack{
                            HStack{
                                Image(systemName: "list.clipboard")
                                    .foregroundStyle(.redSecondary)
                                Text("Recipes")
                            }
                            Spacer()
                                Text(String(recipesCount))
                                .foregroundStyle(.labelSecondary)
                        }
                        .padding(.horizontal, 12.0)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius:16)
                                .foregroundStyle(.backgroundSecondary)
                        )
                    }
                    .padding([.top, .leading, .trailing], 16.0)
                }
            }
            
        }
        .onAppear {
            guard !didLoadFromItem, let existing = item else { return }
            didLoadFromItem = true
            title = existing.name
            selectedIcon = ItemIcon(rawValue: existing.iconRaw) ?? .avocado
            quantity = existing.quantity
            unit = UnitType(rawValue: existing.unitRaw) ?? .units
            description = existing.notes
            hasExpiration = existing.expirationDate != nil
            expirationDate = existing.expirationDate ?? Date()
            alwaysInList = existing.alwaysInList
            recipesCount = existing.recipesCount
            purchaseState = existing.state
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isTitleFocused = false }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isTitleFocused = false
                    let trimmed = trimmedTitle
                    guard isNameValid else {
                        showValidationAlert = true
                        return
                    }
                    if let existing = item {
                        existing.name = trimmed
                        existing.iconRaw = selectedIcon.rawValue
                        existing.quantity = quantity
                        existing.unitRaw = unit.rawValue
                        existing.notes = description
                        existing.expirationDate = hasExpiration ? expirationDate : nil
                        existing.alwaysInList = alwaysInList
                        existing.recipesCount = recipesCount
                        existing.state = purchaseState
                        existing.updatedAt = Date()
                        dismiss()
                    } else {
                        let newItem = StockItem(
                            name: trimmed,
                            iconRaw: selectedIcon.rawValue,
                            quantity: quantity,
                            unitRaw: unit.rawValue,
                            notes: description,
                            expirationDate: hasExpiration ? expirationDate : nil,
                            alwaysInList: alwaysInList,
                            recipesCount: recipesCount,
                            stateRaw: purchaseState.rawValue
                        )
                        modelContext.insert(newItem)
                        dismiss()
                    }
                } label: {
                    Image(systemName: "checkmark")
                }
                .disabled(!isNameValid)
            }
        }
        .alert("Please enter a valid name", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The item must have a valid name.")
        }
    }
}

private struct IconPickerView: View {
    @Binding var selectedIcon: ItemIcon
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.adaptive(minimum: 64), spacing: 16)]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ItemIcon.allCases, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            dismiss()
                        } label: {
                            VStack(spacing: 8) {
                                Image(icon.rawValue)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 48)
                                Text(icon.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
                                    .font(.caption)
                                    .foregroundStyle(.labelSecondary)
                                    .lineLimit(1)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(.backgroundSecondary)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .toolbarBackground(.backgroundPrimary, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    Item().preferredColorScheme(.dark)
}

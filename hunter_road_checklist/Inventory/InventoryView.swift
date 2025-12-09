//
//  InventoryView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/24/25.
//


import SwiftUI

struct InventoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var checklistStore: ChecklistStore
    let onItemCreated: (InventoryItem) -> Void

    init(onItemCreated: @escaping (InventoryItem) -> Void = { _ in }) {
        self.onItemCreated = onItemCreated
    }

    @State private var selectedIndex: Int? = nil
    @State private var isShowingAddItem: Bool = false

    @State private var items: [InventoryItem] = [
        InventoryItem(iconName: "inventory_icon_1", title: "OPTICAL MONOCULAR", quantity: 1, description: "A compact monocular for spotting the bird from a distance."),
        InventoryItem(iconName: "inventory_icon_2", title: "TRAVEL BACKPACK", quantity: 1, description: "A sturdy backpack for carrying essential gear through the forest."),
        InventoryItem(iconName: "inventory_icon_3", title: "FOREST CALL", quantity: 1, description: "A call that mimics partridge sounds, helping you lure the bird gently."),
        InventoryItem(iconName: "inventory_icon_4", title: "FORESTER'S COMPASS", quantity: 1, description: "A simple, non-reflective compass for staying oriented in dense woods."),
        InventoryItem(iconName: "inventory_icon_5", title: "SILENT CLOAK", quantity: 1, description: "A silent cloak that helps you blend into the forest shadows.")
    ]

    var body: some View {
        ZStack {
            Color(red: 39/255.0, green: 46/255.0, blue: 75/255.0)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        InventoryRow(
                            item: item,
                            isSelected: selectedIndex == index,
                            onSelect: {
                                selectedIndex = index
                                isShowingAddItem = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Inventory")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .navigationDestination(isPresented: $isShowingAddItem) {
            if let index = selectedIndex {
                AddInventoryItemView(
                    iconName: items[index].iconName ?? "",
                    baseTitle: items[index].title,
                    baseDescription: items[index].description
                ) { createdItem in
                    onItemCreated(createdItem)
                }
            }
        }
    }
}

private struct InventoryRow: View {
    let item: InventoryItem
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 16) {
                if let iconName = item.iconName {
                    Image(iconName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Rectangle()
                        .opacity(0)
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)

                    Text("Quantity: \(item.quantity)")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(Color.white.opacity(0.9))

                    Text(item.description)
                        .font(.footnote)
                        .foregroundColor(Color.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(red: 1.0, green: 0.8, blue: 0.0) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    InventoryView()
        .environmentObject(ChecklistStore())
        .dynamicTypeSize(.medium)
}

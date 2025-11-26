//
//  EditInventoryItemView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/24/25.
//
import SwiftUI
import PhotosUI

struct EditInventoryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var checklistStore: ChecklistStore

    let item: InventoryItem

    @State private var editableTitle: String
    @State private var editableQuantity: String
    @State private var editableDescription: String
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var localUserImageData: Data? = nil
    @State private var hasLocalImageOverride: Bool = false

    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name
        case quantity
        case description
    }

    init(item: InventoryItem) {
        self.item = item
        _editableTitle = State(initialValue: item.title)
        _editableQuantity = State(initialValue: String(item.quantity))
        _editableDescription = State(initialValue: item.description)
    }

private let backgroundColor = Color(red: 39/255.0, green: 46/255.0, blue: 75/255.0)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // TOP BLOCK: ICON + NAME + QUANTITY
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.06))
                                .frame(width: 120, height: 120)

                            // Предпросмотр картинки / иконки
                            let effectiveImageData: Data? = hasLocalImageOverride ? localUserImageData : item.userImageData
                            
                            if let data = effectiveImageData,
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()                  // заполняем квадрат
                                    .frame(width: 120, height: 120)  // фиксированный размер, как у иконки
                                    .clipped()                       // обрезаем лишнее по краям
                                    .cornerRadius(20)
                            } else if let iconName = item.iconName {
                                Image(iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(20)
                            } else {
                                Rectangle()
                                    .opacity(0)
                                    .frame(width: 120, height: 120)
                            }
                        }
                        .padding(.leading, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            // Name in rectangle
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 56)
                                .overlay(
                                    TextField("Name", text: $editableTitle)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .focused($focusedField, equals: .name)
                                )

                            // Quantity in rectangle
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 56)
                                .overlay(
                                    TextField("Quantity", text: $editableQuantity)
                                        .keyboardType(.numberPad)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .focused($focusedField, equals: .quantity)
                                )
                        }

                        Spacer()
                    }

                    // DESCRIPTION
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
                        .frame(minHeight: 100)
                        .overlay(
                            TextEditor(text: $editableDescription)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.white.opacity(0.9))
                                .font(.subheadline)
                                .padding(12)
                                .focused($focusedField, equals: .description)
                        )

                    // IMAGE INFO TEXT
                    Text("You can upload an image up to 20 MB.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                    // BUTTONS: DELETE IMAGE / UPLOAD NEW IMAGE
                    HStack(spacing: 12) {
                        Button {
                            localUserImageData = nil
                            hasLocalImageOverride = true
                        } label: {
                            ZStack {
                                Image("delete_button")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                HStack(spacing: 8) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Delete image")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ZStack {
                                Image("upload_button")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                HStack(spacing: 4) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16, weight: .semibold))

                                    Text("Upload a new image")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Spacer(minLength: 140)

                    // SAVE CHANGES BUTTON
                    Button {
                        // Создаём итоговый InventoryItem с учётом возможного нового изображения
                        let finalImageData = hasLocalImageOverride ? localUserImageData : item.userImageData

                        let finalQuantity = Int(editableQuantity) ?? item.quantity

                        let finalItem = InventoryItem(
                            id: item.id,
                            iconName: item.iconName,
                            title: editableTitle,
                            quantity: finalQuantity,
                            description: editableDescription,
                            userImageData: finalImageData
                        )

                        if let index = checklistStore.inventoryItems.firstIndex(where: { $0.id == item.id }) {
                            checklistStore.inventoryItems[index] = finalItem
                        }

                        dismiss()
                    } label: {
                        ZStack {
                            Image("save_button")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 52)
                                .clipShape(RoundedRectangle(cornerRadius: 32))

                            Text("Save changes")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onTapGesture {
                focusedField = nil
            }
            .onAppear {
                hasLocalImageOverride = false
                localUserImageData = nil
            }
        }
        
        .onChange(of: selectedPhotoItem) { newItem in
            print("DEBUG: selectedPhotoItem changed:", newItem as Any)

            guard let newItem else {
                print("DEBUG: newItem is nil")
                return
            }

            Task {
                do {
                    let data = try await newItem.loadTransferable(type: Data.self)
                    print("DEBUG: loadTransferable success, data size = \(data?.count ?? 0) bytes")

                    await MainActor.run {
                        localUserImageData = data
                        hasLocalImageOverride = true
                    }

                } catch {
                    print("DEBUG: loadTransferable error:", error.localizedDescription)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit an item")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    checklistStore.deleteInventoryItem(item)
                    dismiss()
                } label: {
                    Image("trash_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
                .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditInventoryItemView(
            item: InventoryItem(
                iconName: "inventory_icon_2",
                title: "TRAVEL BACKPACK",
                quantity: 1,
                description: "A sturdy backpack for carrying essential gear through the forest."
            )
        )
        .environmentObject(ChecklistStore())
    }
}

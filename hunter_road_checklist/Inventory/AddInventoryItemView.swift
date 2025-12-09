//
//  AddInventoryItemView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/24/25.
//

import SwiftUI
import PhotosUI

struct AddInventoryItemView: View {
    @Environment(\.dismiss) private var dismiss

    let iconName: String          // Иконка из InventoryView
    let baseTitle: String         // Базовое название из шаблона
    let baseDescription: String   // Базовое описание из шаблона
    let onSave: (InventoryItem) -> Void

    @State private var name: String
    @State private var quantity: String = ""
    @State private var description: String
    @State private var userImageData: Data? = nil
    @State private var imageError: Bool = false
    @State private var showErrors: Bool = false

    @State private var isShowingPhotoPicker: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name
        case quantity
        case description
    }

    init(
        iconName: String,
        baseTitle: String,
        baseDescription: String,
        onSave: @escaping (InventoryItem) -> Void
    ) {
        self.iconName = iconName
        self.baseTitle = baseTitle
        self.baseDescription = baseDescription
        self.onSave = onSave
        // Start fields empty so placeholders "Name", "Quantity", "Description" are visible
        _name = State(initialValue: "")
        _quantity = State(initialValue: "")
        _description = State(initialValue: "")
    }

    private let errorColor = Color(red: 235/255, green: 76/255, blue: 70/255)

var isNameError: Bool { showErrors && name.isEmpty }
var isQuantityError: Bool { showErrors && quantity.isEmpty }
var isDescriptionError: Bool { showErrors && description.isEmpty }

    var body: some View {
        ZStack {
            Color(red: 39/255.0, green: 46/255.0, blue: 75/255.0)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // NAME FIELD
                    VStack(alignment: .leading, spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(isNameError ? errorColor : Color.clear, lineWidth: 2)
                                )

                            TextField(
                                "",
                                text: $name,
                                prompt: Text("Name")
                                    .foregroundColor(.white.opacity(0.7))
                            )
                            .focused($focusedField, equals: .name)
                            .textInputAutocapitalization(.words)
                            .keyboardType(.default)
                            .padding(.horizontal, 20)
                            .foregroundColor(.white)
                        }
                        .frame(height: 64)

                        if isNameError {
                            Text("Fill in the fields")
                                .foregroundColor(errorColor)
                                .font(.caption)
                        }
                    }

                    // QUANTITY FIELD
                    VStack(alignment: .leading, spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(isQuantityError ? errorColor : Color.clear, lineWidth: 2)
                                )

                            TextField(
                                "",
                                text: $quantity,
                                prompt: Text("Quantity")
                                    .foregroundColor(.white.opacity(0.7))
                            )
                            .focused($focusedField, equals: .quantity)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 20)
                            .foregroundColor(.white)
                        }
                        .frame(height: 64)

                        if isQuantityError {
                            Text("Fill in the fields")
                                .foregroundColor(errorColor)
                                .font(.caption)
                        }
                    }

                    // DESCRIPTION FIELD
                    VStack(alignment: .leading, spacing: 4) {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(isDescriptionError ? errorColor : Color.clear, lineWidth: 2)
                                )

                            TextEditor(text: $description)
                                .focused($focusedField, equals: .description)
                                .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)

                            if description.isEmpty {
                                Text("Description")
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 20)
                                    .foregroundColor(.white.opacity(0.6))
                                    .allowsHitTesting(false)
                            }
                        }
                        .frame(height: 100)

                        if isDescriptionError {
                            Text("Fill in the fields")
                                .foregroundColor(errorColor)
                                .font(.caption)
                        }
                    }

                    // ADD PICTURE BLOCK
                    if let data = userImageData,
                       let uiImage = UIImage(data: data) {
                        // Когда картинка уже выбрана — показываем превью + кнопку Delete
                        HStack(alignment: .center, spacing: 16) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 20))

                            Button {
                                // Удаляем выбранное изображение
                                userImageData = nil
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Delete")
                                        .font(.headline)
                                    Image(systemName: "trash")
                                        .font(.headline)
                                    Spacer()
                                }
                            }
                            .frame(height: 56)
                            .background(Color(red: 211/255, green: 99/255, blue: 94/255))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                        }
                    } else {
                        // Когда картинка ещё не выбрана — показываем рамку Add picture
                        VStack(alignment: .center, spacing: 8) {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                .foregroundColor(imageError ? errorColor : Color.white.opacity(0.3))
                                .frame(height: 170)
                                .overlay(
                                    VStack(spacing: 12) {
                                        Text("Add picture")
                                            .font(.headline)
                                            .foregroundColor(imageError ? errorColor : .white)

                                        Text(imageError ? "Images larger than 20 MB cannot be uploaded.\nPlease choose a smaller file."
                                                        : "You can upload an image up to 20 MB.")
                                            .font(.caption)
                                            .foregroundColor(imageError ? errorColor : .white.opacity(0.7))
                                            .multilineTextAlignment(.center)

                                        Image("icon_upload")
                                            .renderingMode(.template)
                                            .foregroundColor(imageError ? errorColor : .white)
                                            .frame(width: 36, height: 36)
                                    }
                                )
                        }
                        .onTapGesture {
                            isShowingPhotoPicker = true
                        }
                    }

                    Spacer(minLength: 16)

                    // SAVE BUTTON
                    Button {
                        showErrors = true

                        // если все поля заполнены — создаём InventoryItem и передаём дальше
                        if !isNameError && !isQuantityError && !isDescriptionError {
                            let qty = Int(quantity) ?? 0

                            let item = InventoryItem(
                                iconName: iconName,
                                title: name,
                                quantity: qty,
                                description: description,
                                userImageData: userImageData
                            )
                            onSave(item)
                        }
                    } label: {
                        ZStack {
                            Image("save_button")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 32))

                            Text("Save")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 16)
            }
            .onTapGesture {
                focusedField = nil
            }
        }
        .photosPicker(isPresented: $isShowingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { newItem in
            guard let newItem = newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    let maxSize = 20 * 1024 * 1024
                    await MainActor.run {
                        if data.count <= maxSize {
                            userImageData = data
                            imageError = false
                        } else {
                            imageError = true
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Заголовок в центре навбара
            ToolbarItem(placement: .principal) {
                Text("Add an item")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            // Справа в навбаре ничего не показываем (можно убрать или оставить под будущее)
            ToolbarItem(placement: .topBarTrailing) {
                EmptyView()
            }
            // Кнопка Done над клавиатурой
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
        AddInventoryItemView(
            iconName: "inventory_icon_1",
            baseTitle: "OPTICAL MONOCULAR",
            baseDescription: "Preview monocular"
        ) { item in
            // preview stub
            print("Saved item: \(item.title), \(item.quantity), \(item.description)")
        }
        .dynamicTypeSize(.medium)
    }
}

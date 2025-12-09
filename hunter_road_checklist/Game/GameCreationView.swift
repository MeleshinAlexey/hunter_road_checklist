//
//  GameCreationView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/25/25.
//

import SwiftUI
import PhotosUI

struct GameCreationView: View {
    // Чтобы совпасть с тем, как мы уже ссылались на этот экран
    let tab: Tab
    /// Иконка, из которой пришли (например, game_icon_1...6)
    let iconName: String?
    /// Внешний обработчик сохранения игры (если передан).
    let onSave: ((GameItem) -> Void)?

    // Поддержка обоих вариантов: GameCreationView() и GameCreationView(tab: .game)
    init() {
        self.tab = .game
        self.iconName = nil
        self.onSave = nil
    }

    init(tab: Tab) {
        self.tab = tab
        self.iconName = nil
        self.onSave = nil
    }

    init(tab: Tab, iconName: String?) {
        self.tab = tab
        self.iconName = iconName
        self.onSave = nil
    }

    init(tab: Tab, iconName: String?, onSave: @escaping (GameItem) -> Void) {
        self.tab = tab
        self.iconName = iconName
        self.onSave = onSave
    }

    // MARK: - Env / Store
    @EnvironmentObject var checklistStore: ChecklistStore
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var title: String = ""
    @State private var description: String = ""

    @FocusState private var isTitleFocused: Bool
    @FocusState private var isDescriptionFocused: Bool

    // Фото
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var userImageData: Data? = nil
    @State private var imageError: Bool = false

    // Ошибки валидации
    @State private var showErrors: Bool = false
    private let errorColor = Color(red: 235/255.0, green: 76/255.0, blue: 70/255.0)

    private var isNameError: Bool {
        showErrors && title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isDescriptionError: Bool {
        showErrors && description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }


    // Оборудование
    private let allEquipment: [String] = [
        "Steppe Glass",
        "Mist Pouch",
        "Silent Step",
        "Mute Cloak",
        "Winged Compass"
    ]
    @State private var searchText: String = ""
    @State private var selectedEquipment: Set<String> = ["Steppe Glass", "Mist Pouch"]

    var filteredEquipment: [String] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return allEquipment }
        return allEquipment.filter { $0.localizedCaseInsensitiveContains(trimmed) }
    }

    var body: some View {
        ZStack {
            Color(red: 39/255.0, green: 46/255.0, blue: 75/255.0)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // Поле Name
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("", text: $title, prompt: Text("Name").foregroundColor(Color.white.opacity(0.6)))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(isNameError ? errorColor : Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .focused($isTitleFocused)
                            .foregroundColor(.white)
                            .submitLabel(.next)
                            .onSubmit {
                                isDescriptionFocused = true
                            }

                        if isNameError {
                            Text("Fill in the fields")
                                .foregroundColor(errorColor)
                                .font(.caption)
                        }
                    }

                    // Поле Description
                    VStack(alignment: .leading, spacing: 4) {
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Description")
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 16)
                            }

                            TextEditor(text: $description)
                                .frame(minHeight: 120)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .scrollContentBackground(.hidden)
                                .focused($isDescriptionFocused)
                                .foregroundColor(.white)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isDescriptionError ? errorColor : Color.white.opacity(0.12), lineWidth: 1)
                        )

                        if isDescriptionError {
                            Text("Fill in the fields")
                                .foregroundColor(errorColor)
                                .font(.caption)
                        }
                    }

                    // Add picture section:
                    // 1) Если фото ещё не выбрано — большой пунктирный бокс с текстом и иконкой.
                    // 2) Если фото выбрано — картинка слева и кнопка Delete справа.
                    if selectedImage == nil {
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.03))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                imageError ? errorColor : Color.white.opacity(0.4),
                                                style: StrokeStyle(lineWidth: 1, dash: [6, 6])
                                            )
                                    )

                                VStack(spacing: 16) {
                                    Text("Add picture")
                                        .font(.headline)
                                        .foregroundColor(imageError ? errorColor : .white)

                                    Text(imageError
                                         ? "Images larger than 20 MB cannot be uploaded.\nPlease choose a smaller file."
                                         : "You can upload an image up to 20 MB.")
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(imageError ? errorColor : Color.white.opacity(0.7))

                                    Image("icon_upload")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 42, height: 42)
                                        .foregroundColor(imageError ? errorColor : .white)
                                }
                                .padding(.vertical, 32)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } else if let image = selectedImage {
                        HStack(spacing: 16) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 132, height: 132)
                                .clipped()
                                .cornerRadius(24)

                            Spacer()

                            Button {
                                // Удаляем выбранное фото и возвращаемся к состоянию с пунктирным боксом
                                selectedImage = nil
                                selectedPhotoItem = nil
                                userImageData = nil
                                imageError = false
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.white)
                                    Text("Delete")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(red: 204/255, green: 102/255, blue: 102/255))
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 8)
                        }
                    }

                    // Necessary equipment title
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Necessary equipment for hunting:")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)

                        // Search bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.white.opacity(0.7))

                            TextField("Search", text: $searchText)
                                .foregroundColor(.white)
                                .disableAutocorrection(true)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    }

                    // Список экипировки
                    VStack(spacing: 12) {
                        ForEach(filteredEquipment, id: \.self) { item in
                            Button {
                                toggleEquipment(item)
                            } label: {
                                HStack {
                                    Text(item)
                                        .foregroundColor(.white)
                                        .font(.body)

                                    Spacer()

                                    Image(selectedEquipment.contains(item) ? "icon_square_with_checkmark" : "icon_square_without_checkmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color(red: 20/255.0, green: 27/255.0, blue: 60/255.0))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Save button with asset
                    Button {
                        showErrors = true

                        guard !isNameError && !isDescriptionError else {
                            return
                        }

                        saveGame()
                    } label: {
                        ZStack {
                            Image("save_button")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 64)

                            Text("Save")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 18)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let newItem {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        let maxSize = 20 * 1024 * 1024
                        await MainActor.run {
                            if data.count <= maxSize, let uiImage = UIImage(data: data) {
                                self.selectedImage = uiImage
                                self.userImageData = data
                                self.imageError = false
                            } else {
                                self.selectedImage = nil
                                self.userImageData = nil
                                self.imageError = true
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Add game")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
                .foregroundColor(.white)
            }
        }
    }

    // MARK: - Logic

    private func toggleEquipment(_ item: String) {
        if selectedEquipment.contains(item) {
            selectedEquipment.remove(item)
        } else {
            selectedEquipment.insert(item)
        }
    }

    private func saveGame() {
        let finalTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        // Фото, выбранное пользователем (если есть)
        let data = userImageData

        // Всегда сохраняем базовую иконку, с которой пришли (game_icon_1...6),
        // чтобы в EditGameView можно было откатиться к ней после удаления фото.
        // Если по какой-то причине iconName не передан, используем запасную.
        let effectiveIconName: String = iconName ?? "icon_square_without_checkmark"

        let newItem = GameItem(
            id: UUID(),
            iconName: effectiveIconName,
            title: finalTitle.isEmpty ? "New game" : finalTitle,
            description: finalDescription.isEmpty ? "Game description" : finalDescription,
            equipment: Array(selectedEquipment).sorted(),
            userImageData: data
        )

        if let onSave = onSave {
            // Внешний обработчик сам решает, что делать с навигацией
            onSave(newItem)
        } else {
            // Fallback: сохраняем напрямую в стор и закрываем экран здесь
            checklistStore.addGameItem(newItem)
            dismiss()
        }
    }

    private func hideKeyboard() {
        isTitleFocused = false
        isDescriptionFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    NavigationStack {
        GameCreationView()
            .environmentObject(ChecklistStore())
            .dynamicTypeSize(.medium)
    }
}

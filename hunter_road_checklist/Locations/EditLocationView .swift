//
//  EditLocationView .swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/26/25.
//

//
//  EditLocationView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/26/25.
//

import SwiftUI
import PhotosUI

struct EditLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var checklistStore: ChecklistStore

    let location: LocationItem

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var localUserImageData: Data? = nil
    @State private var hasLocalImageOverride: Bool = false
    @State private var searchText: String = ""
    @State private var titleText: String = ""
    @State private var descriptionText: String = ""

    @FocusState private var focusedField: Field?

    private enum Field {
        case title
        case description
    }

    // Временная модель для списка экипировки (отдельная структура, чтобы не конфликтовать с EditGameView)
    private struct LocationEquipmentRowItem: Identifiable, Hashable {
        let id = UUID()
        let name: String
        var isSelected: Bool = false
    }

    private let allEquipment: [String] = [
        "Steppe Glass",
        "Mist Pouch",
        "Silent Step",
        "Mute Cloak",
        "Winged Compass"
    ]

    @State private var equipmentItems: [LocationEquipmentRowItem] = []

    private let backgroundColor = Color(red: 39/255.0, green: 46/255.0, blue: 75/255.0)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // TOP BLOCK: ICON + NAME (точно как в EditGameView)
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.06))
                                .frame(width: 120, height: 120)

                            // Предпросмотр картинки / иконки
                            if let data = (hasLocalImageOverride ? localUserImageData : location.userImageData),
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipped()
                                    .cornerRadius(20)
                            } else if let iconName = location.iconName {
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

                        // NAME RECTANGLE
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 56)
                                .overlay(
                                    TextField(
                                        "",
                                        text: $titleText,
                                        prompt: Text("Name")
                                            .foregroundColor(.white.opacity(0.7))
                                    )
                                    .focused($focusedField, equals: .title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                )
                        }

                        Spacer()
                    }

                    // DESCRIPTION (аналог EditGameView)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
                        .frame(minHeight: 90)
                        .overlay(
                            ZStack(alignment: .topLeading) {
                                if descriptionText.isEmpty {
                                    Text("Description")
                                        .foregroundColor(.white.opacity(0.5))
                                        .font(.subheadline)
                                        .padding(16)
                                }

                                TextEditor(text: $descriptionText)
                                    .focused($focusedField, equals: .description)
                                    .foregroundColor(.white.opacity(0.9))
                                    .font(.subheadline)
                                    .padding(12)
                                    .scrollContentBackground(.hidden)
                            }
                        )

                    // IMAGE INFO TEXT
                    Text("You can upload an image up to 20 MB.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                    // BUTTONS: DELETE IMAGE / UPLOAD NEW IMAGE (как в EditGameView)
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

                    // EQUIPMENT HEADER (тот же текст, что в EditGameView, по твоей просьбе)
                    Text("Necessary equipment for hunting:")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 8)

                    // SEARCH FIELD
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 48)
                        .overlay(
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))

                                TextField("Search", text: $searchText)
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 16)
                        )

                    // EQUIPMENT LIST
                    VStack(spacing: 12) {
                        ForEach(filteredEquipmentIndices, id: \.self) { index in
                            locationEquipmentRow(item: $equipmentItems[index])
                        }
                    }

                    Spacer(minLength: 120)

                    // SAVE CHANGES BUTTON
                    Button {
                        saveChanges()
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
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .onTapGesture {
                focusedField = nil
            }
        }
        .onAppear {
            // При каждом открытии сбрасываем override и подтягиваем актуальные данные из модели
            hasLocalImageOverride = false
            localUserImageData = location.userImageData
            titleText = location.title
            descriptionText = location.description

            equipmentItems = allEquipment.map { name in
                LocationEquipmentRowItem(
                    name: name,
                    isSelected: location.equipment.contains(name)
                )
            }
        }
        .onChange(of: selectedPhotoItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        localUserImageData = data
                        hasLocalImageOverride = true
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit a location")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    checklistStore.deleteLocationItem(location)
                    dismiss()
                } label: {
                    Image("trash_button")
                        .renderingMode(.original)
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

    // MARK: - Equipment helpers

    private var filteredEquipmentIndices: [Int] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return Array(equipmentItems.indices) }

        return equipmentItems.indices.filter { index in
            equipmentItems[index].name
                .lowercased()
                .contains(trimmed.lowercased())
        }
    }

    private func locationEquipmentRow(item: Binding<LocationEquipmentRowItem>) -> some View {
        Button {
            item.wrappedValue.isSelected.toggle()
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .frame(height: 56)
                .overlay(
                    HStack {
                        Text(item.wrappedValue.name)
                            .font(.subheadline)
                            .foregroundColor(.white)

                        Spacer()

                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(Color.white.opacity(0.7), lineWidth: 2)
                                .frame(width: 24, height: 24)

                            if item.wrappedValue.isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                )
        }
        .buttonStyle(.plain)
    }

    private func saveChanges() {
        let trimmedTitle = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)

        let selectedEquipmentNames = equipmentItems
            .filter { $0.isSelected }
            .map { $0.name }

        let finalImageData = hasLocalImageOverride ? localUserImageData : location.userImageData

        let updatedLocation = LocationItem(
            id: location.id,
            iconName: location.iconName,
            title: trimmedTitle.isEmpty ? location.title : trimmedTitle,
            description: trimmedDescription.isEmpty ? location.description : trimmedDescription,
            equipment: selectedEquipmentNames,
            userImageData: finalImageData
        )

        checklistStore.updateLocationItem(updatedLocation)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditLocationView(
            location: LocationItem(
                id: UUID(),
                iconName: "location_icon_1",
                title: "Test Location",
                description: "Example description",
                equipment: ["Steppe Glass", "Mist Pouch"],
                userImageData: nil
            )
        )
        .environmentObject(ChecklistStore())
    }
}

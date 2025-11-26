//
//  ChecklistsView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/24/25.
//

import SwiftUI

struct ChecklistsView: View {
    let tab: Tab
    @EnvironmentObject var checklistStore: ChecklistStore

    @State private var isCreatingChecklist = false
    @State private var isCreatingInventoryItem = false
    @State private var isCreatingGame = false
    @State private var isCreatingLocation = false
    @State private var selectedChecklistItem: ChecklistItem?
    @State private var isEditingChecklist = false
    @State private var selectedInventoryItem: InventoryItem?
    @State private var selectedGameItemID: UUID?
    @State private var selectedLocationItemID: UUID?
    @State private var isEditingInventoryItem = false
    @State private var isEditingGameItem = false
    @State private var isEditingLocationItem = false

    enum SelectedActionTarget {
        case inventory(index: Int)
        case game(index: Int)
        case location(index: Int)
    }

    @State private var selectedActionTarget: SelectedActionTarget?
    @State private var isShowingActionSheet = false

    var body: some View {
        ZStack {
            // Фон на весь экран (включая под таббар и статус-бар)
            Color(red: 39/255.0, green: 46/255.0, blue: 75/255.0)
                .ignoresSafeArea()

            VStack {
                if tab == .checklists && !checklistStore.items.isEmpty {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(checklistStore.items.enumerated()), id: \.element.id) { _, item in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(item.game) + \(item.location)")
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Text(dateFormatter.string(from: item.date))
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.12))
                                )
                                .onTapGesture {
                                    selectedChecklistItem = item
                                    isEditingChecklist = true
                                }
                            }
                        }
                        .padding(.vertical, 24)
                    }
                } else if tab == .inventory && !checklistStore.inventoryItems.isEmpty {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(checklistStore.inventoryItems.enumerated()), id: \.element.id) { index, inv in
                                HStack(spacing: 12) {
                                    if let data = inv.userImageData,
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 48, height: 48)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else if let iconName = inv.iconName {
                                        Image(iconName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 48, height: 48)
                                    } else {
                                        Rectangle()
                                            .opacity(0)
                                            .frame(width: 48, height: 48)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(inv.title)
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        Text("Quantity: \(inv.quantity)")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))

                                        Text(inv.description)
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }

                                    Spacer()
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.12))
                                )
                                .onTapGesture {
                                    if index < checklistStore.inventoryItems.count {
                                        selectedInventoryItem = checklistStore.inventoryItems[index]
                                        isEditingInventoryItem = true
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 24)
                    }
                } else if tab == .game && !checklistStore.gameItems.isEmpty {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(checklistStore.gameItems.enumerated()), id: \.element.id) { index, game in
                                VStack(alignment: .leading, spacing: 8) {
                                    // Большая картинка сохранённой игры:
                                    // если пользователь загрузил фото — показываем его,
                                    // иначе — стандартную сохранённую иконку по шаблону.
                                    if let data = game.userImageData,
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 180)
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                    } else {
                                        Image(gameSaveIconName(for: game))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 180)
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                    }

                                    // Название игры и, опционально, краткое описание
                                    Text(game.title)
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    if !game.description.isEmpty {
                                        Text(game.description)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .lineLimit(2)
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white.opacity(0.08))
                                )
                                .onTapGesture {
                                    if index < checklistStore.gameItems.count {
                                        selectedGameItemID = checklistStore.gameItems[index].id
                                        isEditingGameItem = true
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 24)
                    }
                } else if tab == .locations && !checklistStore.locationItems.isEmpty {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(checklistStore.locationItems.enumerated()), id: \.element.id) { index, loc in
                                VStack(alignment: .leading, spacing: 8) {
                                    // Большая картинка сохранённой локации:
                                    // если пользователь загрузил фото — показываем его,
                                    // иначе — стандартную сохранённую иконку по шаблону.
                                    if let data = loc.userImageData,
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 180)
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                    } else {
                                        Image(locationSaveIconName(for: loc))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 180)
                                            .clipShape(RoundedRectangle(cornerRadius: 24))
                                    }

                                    // Название локации и описание
                                    Text(loc.title)
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    if !loc.description.isEmpty {
                                        Text(loc.description)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .lineLimit(2)
                                    }

                                    if !loc.equipment.isEmpty {
                                        Text("Equipment: \(loc.equipment.count) item(s)")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white.opacity(0.08))
                                )
                                .onTapGesture {
                                    if index < checklistStore.locationItems.count {
                                        selectedLocationItemID = checklistStore.locationItems[index].id
                                        isEditingLocationItem = true
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 24)
                    }
                } else {
                    Spacer()

                    VStack(spacing: 12) {
                        Image("icon_chicken_empty")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)

                        Text(emptyTitle)
                            .font(.title2).bold()
                            .foregroundColor(.white)

                        Text(emptySubtitle)
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()
                }
            }
            .padding(.horizontal, 24)
        }
        // Навигационный заголовок + кнопка +
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(titleText)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    switch tab {
                    case .checklists:
                        isCreatingChecklist = true
                    case .inventory:
                        isCreatingInventoryItem = true
                    case .game:
                        isCreatingGame = true
                    case .locations:
                        isCreatingLocation = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 32, height: 32)

                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $isCreatingChecklist) {
            ChecklistCreationView()
        }
        .navigationDestination(isPresented: $isEditingChecklist) {
            if let checklist = selectedChecklistItem {
                EditChecklistView(checklist: checklist)
                    .id(checklist.id)
            }
        }
        .navigationDestination(isPresented: $isCreatingInventoryItem) {
            InventoryView(onItemCreated: { newItem in
                checklistStore.addInventoryItem(newItem)
                isCreatingInventoryItem = false
            })
        }
        .navigationDestination(isPresented: $isCreatingGame) {
            GameView(onGameCreated: { newGame in
                checklistStore.addGameItem(newGame)
                isCreatingGame = false
            })
        }
        .navigationDestination(isPresented: $isCreatingLocation) {
            LocationView(onLocationCreated: { newLocation in
                checklistStore.addLocationItem(newLocation)
                isCreatingLocation = false
            })
        }
        .navigationDestination(isPresented: $isEditingInventoryItem) {
            if let item = selectedInventoryItem {
                EditInventoryItemView(item: item)
                    .id(item.id)
            }
        }
        .navigationDestination(isPresented: $isEditingGameItem) {
            if let id = selectedGameItemID,
               let game = checklistStore.gameItems.first(where: { $0.id == id }) {
                EditGameView(game: game)
                    .id(game.id)
            }
        }
        .navigationDestination(isPresented: $isEditingLocationItem) {
            if let id = selectedLocationItemID,
               let location = checklistStore.locationItems.first(where: { $0.id == id }) {
                EditLocationView(location: location)
                    .id(location.id)
            }
        }
        .confirmationDialog("Actions", isPresented: $isShowingActionSheet, titleVisibility: .visible) {
            if let target = selectedActionTarget {
                switch target {
                case .inventory(let index):
                    Button("Edit item") {
                        if index < checklistStore.inventoryItems.count {
                            selectedInventoryItem = checklistStore.inventoryItems[index]
                            isEditingInventoryItem = true
                        }
                        selectedActionTarget = nil
                    }

                    Button("Delete item", role: .destructive) {
                        if index < checklistStore.inventoryItems.count {
                            let item = checklistStore.inventoryItems[index]
                            checklistStore.deleteInventoryItem(item)
                        }
                        selectedActionTarget = nil
                    }

                case .game(let index):
                    Button("Edit game") {
                        if index < checklistStore.gameItems.count {
                            selectedGameItemID = checklistStore.gameItems[index].id
                            isEditingGameItem = true
                        }
                        selectedActionTarget = nil
                    }

                    Button("Delete game", role: .destructive) {
                        if index < checklistStore.gameItems.count {
                            let game = checklistStore.gameItems[index]
                            checklistStore.deleteGameItem(game)
                        }
                        selectedActionTarget = nil
                    }
                case .location(let index):
                    Button("Edit location") {
                        if index < checklistStore.locationItems.count {
                            selectedLocationItemID = checklistStore.locationItems[index].id
                            isEditingLocationItem = true
                        }
                        selectedActionTarget = nil
                    }

                    Button("Delete location", role: .destructive) {
                        if index < checklistStore.locationItems.count {
                            let location = checklistStore.locationItems[index]
                            checklistStore.deleteLocationItem(location)
                        }
                        selectedActionTarget = nil
                    }
                }
            }

            Button("Cancel", role: .cancel) {
                selectedActionTarget = nil
            }
        }
    }

    private var titleText: String {
        switch tab {
        case .checklists: return "Checklists"
        case .inventory: return "Inventory"
        case .game: return "Game"
        case .locations: return "Locations"
        }
    }

    private var emptyTitle: String {
        switch tab {
        case .checklists: return "Empty"
        case .inventory: return "No items yet"
        case .game: return "No games yet"
        case .locations: return "No locations yet"
        }
    }

    private var emptySubtitle: String {
        switch tab {
        case .checklists:
            return "Click on the plus sign in the right corner\nto create a checklist"
        case .inventory:
            return "Click on the plus sign in the right corner\nto add an inventory item"
        case .game:
            return "Click on the plus sign in the right corner\nto create a game"
        case .locations:
            return "Click on the plus sign in the right corner\nto add a location"
        }
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    private func gameSaveIconName(for game: GameItem) -> String {
        guard let iconName = game.iconName else {
            return "game_save_icon_1"
        }

        switch iconName {
        case "game_icon_1":
            return "game_save_icon_1"
        case "game_icon_2":
            return "game_save_icon_2"
        case "game_icon_3":
            return "game_save_icon_3"
        case "game_icon_4":
            return "game_save_icon_4"
        case "game_icon_5":
            return "game_save_icon_5"
        case "game_icon_6":
            return "game_save_icon_6"
        default:
            // Запасной вариант, если iconName неожиданно другой
            return "game_save_icon_1"
        }
    }

    private func locationSaveIconName(for location: LocationItem) -> String {
        guard let iconName = location.iconName else {
            return "locations_save_icon_1"
        }

        switch iconName {
        case "locations_icon_1":
            return "locations_save_icon_1"
        case "locations_icon_2":
            return "locations_save_icon_2"
        case "locations_icon_3":
            return "locations_save_icon_3"
        case "locations_icon_4":
            return "locations_save_icon_4"
        case "locations_icon_5":
            return "locations_save_icon_5"
        case "locations_icon_6":
            return "locations_save_icon_6"
        default:
            // Запасной вариант, если iconName неожиданно другой
            return "locations_save_icon_1"
        }
    }
}

#Preview {
    ChecklistsView(tab: .checklists)
        .environmentObject(ChecklistStore())
}

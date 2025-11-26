//
//  ChecklistStore.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/25/25.
//

import Foundation
import SwiftUI
import Combine

/// Хранилище всех созданных чек-листов.
/// Используется как @StateObject в RootTabView и как @EnvironmentObject в других вью.
final class ChecklistStore: ObservableObject {
    /// Все созданные чек-листы (последние сверху).
    @Published var items: [ChecklistItem] = []
    
    /// Все созданные предметы инвентаря (последние сверху).
    @Published var inventoryItems: [InventoryItem] = []

    /// Все созданные игры (последние сверху).
    @Published var gameItems: [GameItem] = []

    @Published var locationItems: [LocationItem] = []

    // MARK: - Persistence

    private struct PersistedData: Codable {
        var items: [ChecklistItem]
        var inventoryItems: [InventoryItem]
        var gameItems: [GameItem]
        var locationItems: [LocationItem]
    }

    /// Файл, в который сохраняем состояние хранилища.
    private var storeURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documents = urls.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return documents.appendingPathComponent("checklist_store.json")
    }

    init() {
        load()
    }

    /// Загрузка сохранённых данных с диска.
    private func load() {
        do {
            let data = try Data(contentsOf: storeURL)
            let decoded = try JSONDecoder().decode(PersistedData.self, from: data)
            self.items = decoded.items
            self.inventoryItems = decoded.inventoryItems
            self.gameItems = decoded.gameItems
            self.locationItems = decoded.locationItems
        } catch {
            // Если файла нет или формат не совпадает — начинаем с пустого состояния.
            // print("ChecklistStore load error:", error)
        }
    }

    /// Сохранение текущего состояния на диск.
    private func save() {
        let snapshot = PersistedData(
            items: items,
            inventoryItems: inventoryItems,
            gameItems: gameItems,
            locationItems: locationItems
        )

        do {
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: storeURL, options: [.atomic])
        } catch {
            // print("ChecklistStore save error:", error)
        }
    }

    /// Добавить новую игру.
    /// - Parameter item: готовый GameItem.
    func addGameItem(_ item: GameItem) {
        gameItems.insert(item, at: 0)
        save()
    }
    func updateGameItem(_ updated: GameItem) {
        if let index = gameItems.firstIndex(where: { $0.id == updated.id }) {
            gameItems[index] = updated
            save()
        }
    }
    
    func deleteGameItem(_ item: GameItem) {
        if let index = gameItems.firstIndex(where: { $0.id == item.id }) {
            gameItems.remove(at: index)
            save()
        }
    }
    
    func addLocationItem(_ item: LocationItem) {
        locationItems.append(item)
        save()
    }

    func updateLocationItem(_ updated: LocationItem) {
        if let index = locationItems.firstIndex(where: { $0.id == updated.id }) {
            locationItems[index] = updated
            save()
        }
    }
    
    func deleteLocationItem(_ item: LocationItem) {
        if let index = locationItems.firstIndex(where: { $0.id == item.id }) {
            locationItems.remove(at: index)
            save()
        }
    }

    /// Добавить новый чек-лист.
    /// - Parameters:
    ///   - game: Название игры (например, "partridge").
    ///   - location: Название локации (например, "Wetlands").
    ///   - date: Дата создания (по умолчанию — сейчас).
    func addChecklist(game: String, location: String, date: Date = Date()) {
        let item = ChecklistItem(
            id: UUID(),
            game: game,
            location: location,
            date: date
        )
        // Добавляем в начало, чтобы самые свежие были сверху
        items.insert(item, at: 0)
        save()
    }
    
    func updateChecklist(_ checklist: ChecklistItem, game: String, location: String) {
        if let index = items.firstIndex(where: { $0.id == checklist.id }) {
            items[index].game = game
            items[index].location = location
            // При желании можно обновить дату:
            // items[index].date = Date()
            save()
        }
    }
    /// Удалить чек-лист.
    func deleteChecklist(_ checklist: ChecklistItem) {
        if let index = items.firstIndex(where: { $0.id == checklist.id }) {
            items.remove(at: index)
            save()
        }
    }
    
    /// Добавить новый предмет инвентаря.
    /// - Parameter item: готовый InventoryItem.
    func addInventoryItem(_ item: InventoryItem) {
        inventoryItems.insert(item, at: 0)
        save()
    }
    /// Удалить предмет инвентаря.
    /// - Parameter item: существующий InventoryItem, который нужно удалить.
    func deleteInventoryItem(_ item: InventoryItem) {
        if let index = inventoryItems.firstIndex(where: { $0.id == item.id }) {
            inventoryItems.remove(at: index)
            save()
        }
    }
}

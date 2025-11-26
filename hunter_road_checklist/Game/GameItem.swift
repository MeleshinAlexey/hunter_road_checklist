//
//  GameItem.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/25/25.
//

import Foundation

struct GameItem: Identifiable, Codable, Hashable {
    let id: UUID
    var iconName: String?        // Иконка (как в InventoryItem)
    var title: String            // Название игры
    var description: String      // Описание игры
    var equipment: [String]      // Выбранное необходимое оборудование
    var userImageData: Data?     // Фото, если пользователь загрузил

    init(
        id: UUID = UUID(),
        iconName: String? = nil,
        title: String,
        description: String,
        equipment: [String] = [],
        userImageData: Data? = nil
    ) {
        self.id = id
        self.iconName = iconName
        self.title = title
        self.description = description
        self.equipment = equipment
        self.userImageData = userImageData
    }
}

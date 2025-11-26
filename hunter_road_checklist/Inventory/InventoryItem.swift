//
//  InventoryItem.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/25/25.
//

import Foundation

struct InventoryItem: Identifiable, Codable, Hashable  {
    let id: UUID
    var iconName: String?       // Иконка из InventoryView, если пользователь не загрузил фото
    var title: String           // Название предмета
    var quantity: Int           // Количество
    var description: String     // Описание
    var userImageData: Data?    // Фото пользователя (опционально)
    
    init(
        id: UUID = UUID(),
        iconName: String? = nil,
        title: String,
        quantity: Int,
        description: String,
        userImageData: Data? = nil
    ) {
        self.id = id
        self.iconName = iconName
        self.title = title
        self.quantity = quantity
        self.description = description
        self.userImageData = userImageData
    }
}

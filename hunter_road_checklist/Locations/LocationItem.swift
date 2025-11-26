//
//  LocationsItem.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/26/25.
//

import Foundation

struct LocationItem: Identifiable, Codable, Hashable {
    let id: UUID
    var iconName: String?      // иконка location_icon_1...N
    var title: String          // название локации
    var description: String    // описание локации
    var equipment: [String]    // нужное снаряжение (если хочешь ту же механику)
    var userImageData: Data?   // пользовательское фото

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

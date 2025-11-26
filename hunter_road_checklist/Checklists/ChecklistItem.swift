//
//  ChecklistItem.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/25/25.
//

import Foundation

struct ChecklistItem: Identifiable, Codable, Hashable {
    let id: UUID
    var game: String     
    var location: String
    var date: Date
}

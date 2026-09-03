//
//  WishlistItem.swift
//  Taste
//
//  Created by Alesya on 30.08.2026.
//

import Foundation

enum WishlistItemType: String, Codable {
    case movie
    case book
    case game
    case music
    case place
    case product
    case freeform
}

struct WishlistItem: Identifiable, Hashable {
    let id: UUID
    let type: WishlistItemType
    let title: String
    let year: Int?
    let imageName: String?

    init(
        id: UUID = UUID(),
        type: WishlistItemType,
        title: String,
        year: Int? = nil,
        imageName: String? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.year = year
        self.imageName = imageName
    }
}

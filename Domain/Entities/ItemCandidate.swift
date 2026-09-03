//
//  ItemCandidate.swift
//  Taste
//
//  Created by Alesya on 01.09.2026.
//

import Foundation

struct ItemCandidate: Identifiable, Hashable {
    let id = UUID()
    let type: WishlistItemType
    let title: String
    let year: Int?

    init(
        type: WishlistItemType,
        title: String,
        year: Int? = nil
    ) {
        self.type = type
        self.title = title
        self.year = year
    }
}

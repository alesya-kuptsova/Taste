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
    let description: String?
    let sourceURL: URL?
    let details: ItemDetails?

    init(
        type: WishlistItemType,
        title: String,
        description: String? = nil,
        sourceURL: URL? = nil,
        details: ItemDetails? = nil
    ) {
        self.type = type
        self.title = title
        self.description = description
        self.sourceURL = sourceURL
        self.details = details
    }
}

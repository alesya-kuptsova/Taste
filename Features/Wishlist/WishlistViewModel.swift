//
//  WishlistViewModel.swift
//  Taste
//
//  Created by Alesya on 30.08.2026.
//

import Foundation
import Observation

@Observable
final class WishlistViewModel {

    private let storageURL: URL = {
        let directory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        return directory
            .appendingPathComponent("Taste", isDirectory: true)
            .appendingPathComponent("wishlist.json")
    }()

    //test
    var items: [WishlistItem] = [
        WishlistItem(
            type: .movie,
            title: "The Handmaiden",
            year: 2016,
            imageName: "poster-handmaiden"
        ),
        WishlistItem(
            type: .movie,
            title: "Oldboy",
            year: 2003,
            imageName: "poster-oldboy"
        ),
        WishlistItem(
            type: .movie,
            title: "Perfect Blue",
            year: 1997,
            imageName: "poster-perfect-blue"
        ),
        WishlistItem(
            type: .movie,
            title: "Mulholland Drive",
            year: 2001,
            imageName: "poster-mulholland"
        )
    ]

    init() {
        loadItems()
    }

    func addItem(from candidate: ItemCandidate) {
        let item = WishlistItem(
            type: candidate.type,
            title: candidate.title,
            description: candidate.description,
            year: candidate.details?.year,
            imageURL: candidate.details?.imageURL,
            originalImageData: candidate.originalImageData
        )

        items.insert(item, at: 0)
    }

    private func saveItems() {
        do {
            let directory = storageURL.deletingLastPathComponent()

            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )

            let data = try JSONEncoder().encode(items)

            try data.write(
                to: storageURL,
                options: .atomic
            )

        } catch {
            print("Failed to save wishlist:", error)
        }
    }

    private func loadItems() {
        guard FileManager.default.fileExists(
            atPath: storageURL.path
        ) else {
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)

            items = try JSONDecoder().decode(
                [WishlistItem].self,
                from: data
            )

        } catch {
            print("Failed to load wishlist:", error)
        }
    }
}

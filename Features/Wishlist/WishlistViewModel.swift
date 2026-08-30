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
}

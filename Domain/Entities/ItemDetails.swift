//
//  ItemDetails.swift
//  Taste
//
//  Created by Alesya on 11.09.2026.
//

import Foundation

struct ItemDetails: Hashable {
    let year: Int?
    let author: String?
    let location: String?
    let mapQuery: String?

    let latitude: Double?
    let longitude: Double?
    let formattedAddress: String?
    let externalPlaceID: String?

    let imageURL: URL?
    let externalURL: URL?

    init(
        year: Int? = nil,
        author: String? = nil,
        location: String? = nil,
        mapQuery: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        formattedAddress: String? = nil,
        externalPlaceID: String? = nil,
        imageURL: URL? = nil,
        externalURL: URL? = nil
    ) {
        self.year = year
        self.author = author
        self.location = location
        self.mapQuery = mapQuery
        self.latitude = latitude
        self.longitude = longitude
        self.formattedAddress = formattedAddress
        self.externalPlaceID = externalPlaceID
        self.imageURL = imageURL
        self.externalURL = externalURL
    }
}

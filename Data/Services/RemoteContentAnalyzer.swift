//
//  RemoteContentAnalyzer.swift
//  Taste
//
//  Created by Alesya on 04.09.2026.
//

import Foundation

final class RemoteContentAnalyzer: ContentAnalyzer {

    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func analyze(_ input: ImportInput) async throws -> [ItemCandidate] {
        let url = baseURL.appendingPathComponent("api/Analyze")

        let rawInput: String

        switch input {
        case .text(let text):
            rawInput = text

        case .url(let url):
            rawInput = url.absoluteString
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = try JSONEncoder().encode(
            AnalyzeRequest(input: rawInput)
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RemoteContentAnalyzerError.invalidResponse
        }

        let result = try JSONDecoder().decode(
            AnalyzeResponse.self,
            from: data
        )
        return result.candidates.map {
            ItemCandidate(
                type: WishlistItemType(rawValue: $0.type) ?? .freeform,
                title: $0.title,
                description: $0.description,
                sourceURL: $0.sourceUrl.flatMap(URL.init(string:)),
                details: $0.details.map {
                    ItemDetails(
                        year: $0.year,
                        author: $0.author,
                        location: $0.location,
                        mapQuery: $0.mapQuery,
                        latitude: $0.latitude,
                        longitude: $0.longitude,
                        formattedAddress: $0.formattedAddress,
                        externalPlaceID: $0.externalPlaceId,
                        imageURL: $0.imageUrl.flatMap(URL.init(string:)),
                        externalURL: $0.externalUrl.flatMap(URL.init(string:))
                    )
                }
            )
        }
    }
}

private struct AnalyzeRequest: Encodable {
    let input: String
}

private struct AnalyzeResponse: Decodable {
    let candidates: [ItemCandidateDTO]
}

private struct ItemCandidateDTO: Decodable {
    let type: String
    let title: String
    let description: String?
    let sourceUrl: String?
    let details: ItemDetailsDTO?
}

private struct ItemDetailsDTO: Decodable {
    let year: Int?
    let author: String?
    let location: String?
    let mapQuery: String?

    let latitude: Double?
    let longitude: Double?
    let formattedAddress: String?
    let externalPlaceId: String?

    let imageUrl: String?
    let externalUrl: String?
}

private enum RemoteContentAnalyzerError: Error {
    case invalidResponse
}

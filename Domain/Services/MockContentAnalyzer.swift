//
//  MockContentAnalyzer.swift
//  Taste
//
//  Created by Alesya on 01.09.2026.
//

import Foundation

final class MockContentAnalyzer: ContentAnalyzer {
    func analyze(_ input: ImportInput) async throws -> [ItemCandidate] {
        switch input {
        case .text(let text):
            return analyzeText(text)

        case .url(let url):
            return [
                ItemCandidate(
                    type: .freeform,
                    title: "Saved link: \(url.absoluteString)"
                )
            ]
        }
    }

    private func analyzeText(_ text: String) -> [ItemCandidate] {
        let normalized = text.lowercased()

        if normalized.contains("oldboy") ||
            normalized.contains("олдбой") {

            return [
                ItemCandidate(
                    type: .movie,
                    title: "Oldboy",
                    year: 2003
                )
            ]
        }

        return [
            ItemCandidate(
                type: .freeform,
                title: text
            )
        ]
    }
}

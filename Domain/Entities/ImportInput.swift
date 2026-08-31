//
//  ImportInput.swift
//  Taste
//
//  Created by Alesya on 31.08.2026.
//

import Foundation

enum ImportInput {
    case text(String)
    case url(URL)

    init?(rawValue: String) {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedValue.isEmpty else {
            return nil
        }

        if let url = URL(string: trimmedValue),
           let scheme = url.scheme,
           scheme == "http" || scheme == "https" {
            self = .url(url)
        } else {
            self = .text(trimmedValue)
        }
    }
}

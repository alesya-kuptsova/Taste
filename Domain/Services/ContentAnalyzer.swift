//
//  ContentAnalyzer.swift
//  Taste
//
//  Created by Alesya on 01.09.2026.
//

import Foundation

protocol ContentAnalyzer {
    func analyze(_ input: ImportInput) async throws -> [ItemCandidate]
}

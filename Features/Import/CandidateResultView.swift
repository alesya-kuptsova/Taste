//
//  CandidateResultView.swift
//  Taste
//
//  Created by Alesya on 01.09.2026.
//

import SwiftUI

struct CandidateResultView: View {
    let candidate: ItemCandidate
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("We found")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(candidate.title)
                    .font(.title3.bold())

                Text(candidate.type.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let year = candidate.year {
                    Text(String(year))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                onConfirm()
            } label: {
                Text("Add to Wishlist")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(AppSpacing.lg)
    }
}

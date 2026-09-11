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

                if let description = candidate.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if candidate.type == .place,
                   let latitude = candidate.details?.latitude,
                   let longitude = candidate.details?.longitude {

                    let title = candidate.title
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        ?? candidate.title

                    if let mapsURL = URL(
                        string: "https://maps.apple.com/?ll=\(latitude),\(longitude)&q=\(title)"
                    ) {
                        Link(destination: mapsURL) {
                            Label("Open in Maps", systemImage: "map")
                        }
                    }
                }

                HStack(spacing: 6) {
                    Text(candidate.type.rawValue.capitalized)

                    if let year = candidate.details?.year {
                        Text("•")
                        Text(String(year))
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
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

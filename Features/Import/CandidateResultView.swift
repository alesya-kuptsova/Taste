//
//  CandidateResultView.swift
//  Taste
//
//  Created by Alesya on 01.09.2026.
//

import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

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

                
                if candidate.type == .product,
                   let imageData = candidate.originalImageData {

                    // For products, prefer the original user image
                    OriginalImageView(imageData: imageData)

                } else if let imageURL = candidate.details?.imageURL {

                    // For movies, books, games and other items,
                    // prefer the identified catalog image
                    AsyncImage(url: imageURL) { phase in
                        switch phase {

                        case .empty:
                            ProgressView()
                                .frame(height: 220)

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 220)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 12)
                                )

                        case .failure:
                            if let imageData = candidate.originalImageData {
                                OriginalImageView(imageData: imageData)
                            } else {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                                    .frame(height: 120)
                            }

                        @unknown default:
                            EmptyView()
                        }
                    }

                } else if let imageData = candidate.originalImageData {

                    // Fallback when no catalog image was found
                    OriginalImageView(imageData: imageData)

                } else {

                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(height: 120)
                }
                
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
    
    private struct OriginalImageView: View {

        let imageData: Data

        var body: some View {

            #if os(macOS)
            if let image = NSImage(data: imageData) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            #elseif os(iOS)
            if let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            #endif
        }
    }
}

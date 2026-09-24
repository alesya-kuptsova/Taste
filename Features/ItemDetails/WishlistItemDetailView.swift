//
//  WishlistItemDetailView.swift
//  Taste
//
//  Created by Alesya on 25.09.2026.
//

import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct WishlistItemDetailView: View {

    let item: WishlistItem

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: AppSpacing.lg
            ) {

                itemImage

                Text(item.title)
                    .font(.title.bold())

                HStack(spacing: AppSpacing.sm) {

                    Text(item.type.rawValue.capitalized)

                    if let year = item.year {
                        Text("•")
                        Text(String(year))
                    }

                    if let description = item.description,
                       !description.isEmpty {

                        VStack(alignment: .leading, spacing: 8) {

                            Text("Description")
                                .font(.title3.bold())

                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                        }
                        .padding(.top, 16)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

            }
            .frame(maxWidth: 600, alignment: .leading)
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity)
        }
        .background(AppColors.background)
        .navigationTitle(item.title)
    }

    @ViewBuilder
    private var itemImage: some View {

        if item.type == .product,
           let data = item.originalImageData {

            originalImage(data)

        } else if let imageURL = item.imageURL {

            AsyncImage(url: imageURL) { phase in

                switch phase {

                case .success(let image):
                    styledImage(image)

                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)

                case .failure:
                    if let data = item.originalImageData {
                        originalImage(data)
                    } else {
                        placeholder
                    }

                @unknown default:
                    placeholder
                }
            }

        } else if let imageName = item.imageName {

            styledImage(Image(imageName))

        } else if let data = item.originalImageData {

            originalImage(data)

        } else {

            placeholder
        }
    }

    private func styledImage(_ image: Image) -> some View {

        image
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.card)
            )
    }

    @ViewBuilder
    private func originalImage(_ data: Data) -> some View {

        #if os(macOS)
        if let image = NSImage(data: data) {
            styledImage(Image(nsImage: image))
        } else {
            placeholder
        }
        #elseif os(iOS)
        if let image = UIImage(data: data) {
            styledImage(Image(uiImage: image))
        } else {
            placeholder
        }
        #endif
    }

    private var placeholder: some View {

        RoundedRectangle(cornerRadius: AppRadius.card)
            .fill(AppColors.cardBackground)
            .frame(height: 320)
            .overlay {

                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
    }
}

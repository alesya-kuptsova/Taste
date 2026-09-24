//
//  MovieCardView.swift
//  Taste
//
//  Created by Alesya on 30.08.2026.
//

import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct MovieCardView: View {

    let item: WishlistItem

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {

            poster

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if let year = item.year {
                    Text(String(year))
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
        .frame(width: AppSize.posterWidth, alignment: .leading)
    }

    @ViewBuilder
    private var poster: some View {

        // Products added from an image:
        // prefer the original user photo.
        if item.type == .product,
           let imageData = item.originalImageData {

            originalImageView(imageData)

        } else if let imageURL = item.imageURL {

            AsyncImage(url: imageURL) { phase in
                switch phase {

                case .success(let image):
                    posterStyle(image)

                case .empty:
                    ProgressView()
                        .frame(
                            width: AppSize.posterWidth,
                            height: AppSize.posterHeight
                        )

                case .failure:
                    if let imageData = item.originalImageData {
                        originalImageView(imageData)
                    } else {
                        placeholder
                    }

                @unknown default:
                    placeholder
                }
            }

        } else if let imageName = item.imageName {

            posterStyle(Image(imageName))

        } else if let imageData = item.originalImageData {

            originalImageView(imageData)

        } else {

            placeholder
        }
    }
    
    
    private func posterStyle(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(
                width: AppSize.posterWidth,
                height: AppSize.posterHeight
            )
            .clipped()
            .clipShape(
                RoundedRectangle(cornerRadius: AppRadius.card)
            )
    }

    @ViewBuilder
    private func originalImageView(_ data: Data) -> some View {

        #if os(macOS)
        if let image = NSImage(data: data) {
            posterStyle(Image(nsImage: image))
        } else {
            placeholder
        }
        #elseif os(iOS)
        if let image = UIImage(data: data) {
            posterStyle(Image(uiImage: image))
        } else {
            placeholder
        }
        #endif
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: AppRadius.card)
            .fill(AppColors.cardBackground)
            .frame(
                width: AppSize.posterWidth,
                height: AppSize.posterHeight
            )
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
    }

    @ViewBuilder
    static func thumbnail(for item: WishlistItem) -> some View {
        WishlistThumbnailView(item: item)
    }
}
private struct WishlistThumbnailView: View {

    let item: WishlistItem

    var body: some View {
        Group {
            if item.type == .product,
               let data = item.originalImageData {
                originalImage(data)

            } else if let imageURL = item.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure:
                        if let data = item.originalImageData {
                            originalImage(data)
                        } else {
                            placeholder
                        }

                    default:
                        placeholder
                    }
                }

            } else if let imageName = item.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()

            } else if let data = item.originalImageData {
                originalImage(data)

            } else {
                placeholder
            }
        }
    }

    @ViewBuilder
    private func originalImage(_ data: Data) -> some View {
        #if os(macOS)
        if let image = NSImage(data: data) {
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
        } else {
            placeholder
        }
        #elseif os(iOS)
        if let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            placeholder
        }
        #endif
    }

    private var placeholder: some View {
        Rectangle()
            .fill(AppColors.cardBackground)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
    }
}

//
//  MovieCardView.swift
//  Taste
//
//  Created by Alesya on 30.08.2026.
//

import SwiftUI

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
        if let imageURL = item.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: AppSize.posterWidth,
                            height: AppSize.posterHeight
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: AppRadius.card)
                        )

                default:
                    placeholder
                }
            }

        } else if let imageName = item.imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(
                    width: AppSize.posterWidth,
                    height: AppSize.posterHeight
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                )

        } else {
            placeholder
        }
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
}

//
//  AllWishlistView.swift
//  Taste
//
//  Created by Alesya on 25.09.2026.
//

import SwiftUI

struct AllWishlistView: View {

    let items: [WishlistItem]
    @State private var selectedCategory: WishlistItemType? = nil
    
    private var filteredItems: [WishlistItem] {
        guard let selectedCategory else {
            return items
        }
        return items.filter { $0.type == selectedCategory }
    }

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.lg
            ) {
                header

                categoryFilter

                wishlistItems
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .navigationTitle("All Wishlist")
    }

    private var header: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.xs
        ) {
            Text("All Wishlist")
                .font(.largeTitle.bold())

            Text("\(items.count) things saved")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                categoryButton(
                    title: "All",
                    category: nil
                )

                categoryButton(
                    title: "Movies",
                    category: .movie
                )

                categoryButton(
                    title: "Products",
                    category: .product
                )

                categoryButton(
                    title: "Places",
                    category: .place
                )

                categoryButton(
                    title: "Books",
                    category: .book
                )

                categoryButton(
                    title: "Games",
                    category: .game
                )

                categoryButton(
                    title: "Music",
                    category: .music
                )

                categoryButton(
                    title: "Other",
                    category: .freeform
                )
            }
        }
    }

    private func categoryButton(
        title: String,
        category: WishlistItemType?
    ) -> some View {
        Button {
            selectedCategory = category
        } label: {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
        }
        
        .buttonStyle(.bordered)
        .tint(
            selectedCategory == category
                ? .accentColor
                : .secondary
        )
    }

    private var wishlistItems: some View {
        LazyVStack(
            alignment: .leading,
            spacing: AppSpacing.md
        ) {
            ForEach(filteredItems) { item in
                NavigationLink {
                    WishlistItemDetailView(item: item)
                } label: {
                    HStack(spacing: AppSpacing.md) {
                        MovieCardView.thumbnail(for: item)
                            .frame(width: 52, height: 78)
                            .clipped()
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: AppRadius.small
                                )
                            )

                        VStack(
                            alignment: .leading,
                            spacing: AppSpacing.xs
                        ) {
                            Text(item.title)
                                .font(.headline)
                                .lineLimit(2)

                            if let year = item.year {
                                Text(
                                    "\(year) · \(item.type.rawValue.capitalized)"
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            } else {
                                Text(item.type.rawValue.capitalized)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

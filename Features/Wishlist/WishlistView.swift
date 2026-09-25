//
//  WishlistView.swift
//  Taste
//
//  Created by Alesya on 30.08.2026.
//

import SwiftUI

struct WishlistView: View {

    @State private var viewModel = WishlistViewModel()
    @State private var isShowingAddItem = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {

                    header

                    movieCarousel

                    recentlyAdded
                }
                .padding(.vertical, AppSpacing.lg)
            }
            .background(AppColors.background)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddItem) {
                AddItemView(
                    analyzer: RemoteContentAnalyzer(
                        baseURL: URL(string: "https://localhost:7077")!
                    )
                ) { candidate in
                    viewModel.addItem(from: candidate)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("My Wishlist")
                .font(.largeTitle.bold())

            Text("\(viewModel.items.count) things saved")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private var movieCarousel: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {

            Text("Movies")
                .font(.title2.bold())
                .padding(.horizontal, AppSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: AppSpacing.md) {
                    ForEach(viewModel.items) { item in
                        NavigationLink {
                            WishlistItemDetailView(item: item)
                        } label: {
                            MovieCardView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)
            }
            .frame(height: AppSize.posterHeight + 75)
        }
    }

    private var recentlyAdded: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Recently Added")
                    .font(.title2.bold())

                Spacer()

                NavigationLink {
                    AllWishlistView(items: viewModel.items)
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Text("See All")

                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }

            ForEach(viewModel.items.prefix(3)) { item in
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: iconName(for: item.type))
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 52, height: 52)
                        .background(
                            AppColors.cardBackground,
                            in: RoundedRectangle(cornerRadius: AppRadius.small)
                        )

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {

                        Text(item.title)
                            .font(.headline)
                            .lineLimit(1)

                        if let year = item.year {
                            Text(String(year))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(item.type.rawValue.capitalized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private func iconName(for type: WishlistItemType) -> String {
        switch type {
        case .movie:
            return "film"

        case .book:
            return "book.closed"

        case .game:
            return "gamecontroller"

        case .music:
            return "music.note"

        case .place:
            return "mappin.and.ellipse"

        case .product:
            return "bag"

        case .freeform:
            return "heart"
        }
    }
}

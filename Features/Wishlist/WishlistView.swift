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
                AddItemView { candidate in
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
                LazyHStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.items) { item in
                        MovieCardView(item: item)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
            }
        }
    }

    private var recentlyAdded: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {

            Text("Recently Added")
                .font(.title2.bold())

            ForEach(viewModel.items.prefix(3)) { item in
                HStack(spacing: AppSpacing.md) {

                    if let imageName = item.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 78)
                            .clipShape(
                                RoundedRectangle(cornerRadius: AppRadius.small)
                            )
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(item.title)
                            .font(.headline)

                        if let year = item.year {
                            Text(String(year))
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
}

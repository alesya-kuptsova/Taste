//
//  AddItemView.swift
//  Taste
//
//  Created by Alesya on 31.08.2026.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers


#if os(macOS)
import AppKit
private typealias PlatformImage = NSImage
#elseif os(iOS)
import UIKit
private typealias PlatformImage = UIImage
#endif

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var input = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isLoadingImage = false
    @State private var errorMessage: String?
    @State private var candidate: ItemCandidate?
    @State private var isAnalyzing = false
    @State private var isFileImporterPresented = false
    
    private let analyzer: ContentAnalyzer

    let onAddItem: (ItemCandidate) -> Void
    
    init(
        analyzer: ContentAnalyzer,
        onAddItem: @escaping (ItemCandidate) -> Void
    ) {
        self.analyzer = analyzer
        self.onAddItem = onAddItem
    }

    private var inputForm: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            TextField("Title, description or link", text: $input)
                .textFieldStyle(.roundedBorder)

            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images
            ) {
                Label(
                    "Attach image",
                    systemImage: "photo.badge.plus"
                )
            }
            .buttonStyle(.bordered)
            
            Button {
                isFileImporterPresented = true
            } label: {
                Label(
                    "Choose image from files",
                    systemImage: "folder"
                )
            }
            .buttonStyle(.bordered)
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [.png, .jpeg, .webP],
                allowsMultipleSelection: false
            ) { result in
                do {
                    guard let url = try result.get().first else {
                        return
                    }

                    let hasAccess = url.startAccessingSecurityScopedResource()

                    defer {
                        if hasAccess {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }

                    let data = try Data(contentsOf: url)

                    guard PlatformImage(data: data) != nil else {
                        errorMessage = "Unsupported image format."
                        return
                    }

                    selectedImageData = data
                    selectedPhoto = nil
                    errorMessage = nil

                } catch {
                    errorMessage = "Could not load image: \(error.localizedDescription)"
                }
            }
            
            .onChange(of: selectedPhoto) { newPhoto in
                selectedImageData = nil

                guard let newPhoto else {
                    return
                }

                isLoadingImage = true

                Task {
                    defer {
                        isLoadingImage = false
                    }

                    do {
                        guard let data = try await newPhoto.loadTransferable(
                            type: Data.self
                        ) else {
                            errorMessage = "Could not load the selected image."
                            return
                        }

                        guard PlatformImage(data: data) != nil else {
                            errorMessage = "Unsupported image format."
                            return
                        }

                        selectedImageData = data
                        errorMessage = nil

                    } catch {
                        errorMessage = "Could not load image: \(error.localizedDescription)"
                    }
                }
            }
            
            if isLoadingImage {
                ProgressView("Loading image...")
            }

            if let selectedImageData,
               let platformImage = PlatformImage(data: selectedImageData) {

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
#if os(macOS)
                    Image(nsImage: platformImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
#elseif os(iOS)
                    Image(uiImage: platformImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
#endif

                    Button(role: .destructive) {
                        selectedPhoto = nil
                        self.selectedImageData = nil
                    } label: {
                        Label("Remove image", systemImage: "trash")
                    }
                }
            }
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("What do you want to save?")
                    .font(.title2.bold())

                Text("Enter a title, description or paste a link.")
                    .foregroundStyle(.secondary)
            }

//            TextField("Title, description or link", text: $input)
//                .textFieldStyle(.roundedBorder)

            if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }

            Button {
                Task {
                    await analyzeInput()
                }
            } label: {
                if isAnalyzing {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(
                isAnalyzing ||
                isLoadingImage ||
                (
                    input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                    selectedImageData == nil
                )
            )
            
            .disabled(
                isAnalyzing ||
                isLoadingImage ||
                (
                    input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                    selectedImageData == nil
                )
            )

            Spacer()
        }
        .padding(AppSpacing.lg)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let candidate {
                    CandidateResultView(candidate: candidate) {
                        onAddItem(candidate)
                        dismiss()
                    }
                } else {
                    inputForm
                }
            }
            .navigationTitle("Add to Taste")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }


    @MainActor
    private func analyzeInput() async {

        let trimmedInput = input.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        // Require either text or an image
        guard !trimmedInput.isEmpty ||
              selectedImageData != nil else {
            return
        }

        isAnalyzing = true
        errorMessage = nil

        defer {
            isAnalyzing = false
        }

        do {
            let candidates: [ItemCandidate]

            if let imageData = selectedImageData {

                // Analyze image with optional text or URL
                candidates = try await analyzer.analyzeImage(
                    input: trimmedInput,
                    imageData: imageData
                )

            } else {

                // Analyze text or URL without an image
                guard let importInput = ImportInput(
                    rawValue: trimmedInput
                ) else {
                    errorMessage = "Please enter a valid description or URL."
                    return
                }

                candidates = try await analyzer.analyze(
                    importInput
                )
            }


            if let firstCandidate = candidates.first {

                candidate = ItemCandidate(
                    type: firstCandidate.type,
                    title: firstCandidate.title,
                    description: firstCandidate.description,
                    sourceURL: firstCandidate.sourceURL,
                    details: firstCandidate.details,
                    originalImageData: selectedImageData
                )

            } else {
                errorMessage = "No matching items found."
            }

        } catch {
            print("Analyze error:", error)

            errorMessage =
                "Could not analyze this item: \(error.localizedDescription)"
        }
    }
}

//
//  AddItemView.swift
//  Taste
//
//  Created by Alesya on 31.08.2026.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var input = ""
    @State private var errorMessage: String?
    @State private var candidate: ItemCandidate?
    @State private var isAnalyzing = false
    
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
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("What do you want to save?")
                    .font(.title2.bold())

                Text("Enter a title, description or paste a link.")
                    .foregroundStyle(.secondary)
            }

            TextField("Title, description or link", text: $input)
                .textFieldStyle(.roundedBorder)

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
                input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
        guard let importInput = ImportInput(rawValue: input) else {
            return
        }

        isAnalyzing = true
        errorMessage = nil

        do {
            let candidates = try await analyzer.analyze(importInput)

            candidate = candidates.first
        } catch {
            print("Analyze error:", error)
            errorMessage = "Could not analyze this item: \(error.localizedDescription)"
        }

        isAnalyzing = false
    }
}

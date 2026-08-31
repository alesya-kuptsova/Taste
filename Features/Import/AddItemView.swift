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

    let onAddItem: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("What do you want to save?")
                        .font(.title2.bold())

                    Text("Enter a movie title or paste a link.")
                        .foregroundStyle(.secondary)
                }

                TextField("Movie title or link", text: $input)
                    .textFieldStyle(.roundedBorder)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                Button {
                    handleInput()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )

                Spacer()
            }
            .padding(AppSpacing.lg)
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

    private func handleInput() {
        guard let importInput = ImportInput(rawValue: input) else {
            return
        }

        switch importInput {
        case .text(let text):
            onAddItem(text)
            dismiss()

        case .url:
            errorMessage = "Link import is not available yet."
        }
    }
}

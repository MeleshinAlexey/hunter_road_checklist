//
//  SwiftUIView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/24/25.
//

import SwiftUI

struct ChecklistCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var checklistStore: ChecklistStore

    // Данные из макета
    private let games = [
        "Partridge", "Pheasant", "Quail", "Duck", "Goose",
        "Hare", "Boar", "Roe Deer", "Red Deer"
    ]

    private let locations = [
        "Forest", "Grasslands", "Wetlands", "Mountains", "Riverbanks"
    ]

    // Выбранные значения (по одному)
    @State private var selectedGame: String? = "Partridge"
    @State private var selectedLocation: String? = "Forest"

    var body: some View {
        ZStack {
            // фон как на главном экране
            Color(red: 39/255.0, green: 46/255.0, blue: 75/255.0)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 24) {

                        // --- блок game ---
                        Text("Choose a game:")
                            .font(.title2).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)

                        VStack(spacing: 12) {
                            ForEach(games, id: \.self) { game in
                                ChecklistOptionRow(
                                    title: game,
                                    isSelected: selectedGame == game
                                ) {
                                    selectedGame = game
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // --- блок location ---
                        Text("Choose a location:")
                            .font(.title2).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)

                        VStack(spacing: 12) {
                            ForEach(locations, id: \.self) { location in
                                ChecklistOptionRow(
                                    title: location,
                                    isSelected: selectedLocation == location
                                ) {
                                    selectedLocation = location
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 16)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                }

                // --- кнопка Save внизу ---
                Button {
                    if let game = selectedGame,
                       let location = selectedLocation {
                        checklistStore.addChecklist(game: game, location: location)
                    }
                    dismiss()
                } label: {
                    ZStack {
                        Image("save_button")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 30))

                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // центрированный белый заголовок
            ToolbarItem(placement: .principal) {
                Text("Creating a checklist")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

/// Одна строка списка с чекбоксом
struct ChecklistOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(isSelected
                      ? "icon_square_with_checkmark"
                      : "icon_square_without_checkmark")
                    .resizable()
                    .frame(width: 24, height: 24)

                Text(title)
                    .foregroundColor(.white)
                    .font(.body)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.06))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ChecklistCreationView()
            .environmentObject(ChecklistStore())
    }
}

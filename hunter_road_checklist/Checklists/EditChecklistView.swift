//
//  EditChecklistView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/30/25.
//



import SwiftUI

struct EditChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var checklistStore: ChecklistStore

    let checklist: ChecklistItem

    // Данные из макета (те же, что и в ChecklistCreationView)
    private let games = [
        "Partridge", "Pheasant", "Quail", "Duck", "Goose",
        "Hare", "Boar", "Roe Deer", "Red Deer"
    ]

    private let locations = [
        "Forest", "Grasslands", "Wetlands", "Mountains", "Riverbanks"
    ]

    // Выбранные значения (по одному), инициализируются из checklist
    @State private var selectedGame: String
    @State private var selectedLocation: String

    init(checklist: ChecklistItem) {
        self.checklist = checklist
        _selectedGame = State(initialValue: checklist.game)
        _selectedLocation = State(initialValue: checklist.location)
    }

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
                    // логика обновления сохранённого чеклиста
                    // метод updateChecklist будет добавлен в ChecklistStore на следующем шаге
                    checklistStore.updateChecklist(
                        checklist,
                        game: selectedGame,
                        location: selectedLocation
                    )
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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    checklistStore.deleteChecklist(checklist)
                    dismiss()
                } label: {
                    Image("trash_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width:50, height: 50)
                }
            }

            // центрированный белый заголовок
            ToolbarItem(placement: .principal) {
                Text("Editing a checklist")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditChecklistView(
            checklist: ChecklistItem(
                id: UUID(),
                game: "Partridge",
                location: "Forest",
                date: Date()
            )
        )
        .environmentObject(ChecklistStore())
    }
}

//
//  GameView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/26/25.
//

import SwiftUI

struct GameDefinition: Identifiable, Hashable {
    let id = UUID()
    let iconName: String
    let title: String
}

struct GameView: View {
    /// Called when a new game is created and should be propagated back to the parent (e.g. ChecklistsView).
    let onGameCreated: (GameItem) -> Void

    init(onGameCreated: @escaping (GameItem) -> Void = { _ in }) {
        self.onGameCreated = onGameCreated
    }

    // MARK: - Colors
    private let backgroundColor = Color(red: 39/255.0, green: 46/255.0, blue: 75/255.0)
    private let cardBackgroundColor = Color(red: 26/255.0, green: 33/255.0, blue: 63/255.0)

    @EnvironmentObject var checklistStore: ChecklistStore

    // MARK: - Navigation state
    @State private var selectedTemplate: GameDefinition? = nil
    @State private var isCreatingGame: Bool = false
    @State private var selectedGameItem: GameItem? = nil
    @State private var isEditingGame: Bool = false

    // MARK: - Games
    private let games: [GameDefinition] = [
        GameDefinition(iconName: "game_icon_1", title: "PARTRIDGE"),
        GameDefinition(iconName: "game_icon_2", title: "RED DEER"),
        GameDefinition(iconName: "game_icon_3", title: "HARE"),
        GameDefinition(iconName: "game_icon_4", title: "WILD BOAR"),
        GameDefinition(iconName: "game_icon_5", title: "WILD DUCK"),
        GameDefinition(iconName: "game_icon_6", title: "PHEASANT")
    ]

    // MARK: - Grid layout
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with centered title and plus button on the right
                    HStack {
                        Spacer()
                    }
                    .frame(height: 44)
                    .overlay(
                        Text("Wild game")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white),
                        alignment: .center
                    )
                    .padding(.top, 8)

                    // Grid with game icons
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        ForEach(games) { game in
                            Button {
                                selectedTemplate = game
                                isCreatingGame = true
                            } label: {
                                WildGameCardView(
                                    title: game.title,
                                    imageName: game.iconName,
                                    cardBackgroundColor: cardBackgroundColor
                                )
                            }
                        }
                    }

                    // Saved games list
                    if !checklistStore.gameItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Saved games")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.top, 8)

                            ForEach(checklistStore.gameItems) { game in
                                Button {
                                    selectedGameItem = game
                                    isEditingGame = true
                                } label: {
                                    HStack(spacing: 12) {
                                        // Preview image: user image if present, otherwise icon
                                        if let data = game.userImageData,
                                           let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 56, height: 56)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                        } else if let iconName = game.iconName {
                                            Image(iconName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 56, height: 56)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                        } else {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white.opacity(0.06))
                                                .frame(width: 56, height: 56)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(game.title)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)

                                            if !game.description.isEmpty {
                                                Text(game.description)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .lineLimit(2)
                                            }
                                        }

                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(cardBackgroundColor)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationDestination(isPresented: $isCreatingGame) {
            if let template = selectedTemplate {
                GameCreationView(
                    tab: .game,
                    iconName: template.iconName,
                    onSave: { newGame in
                        onGameCreated(newGame)
                    }
                )
            }
        }
        .navigationDestination(isPresented: $isEditingGame) {
            if let game = selectedGameItem {
                EditGameView(game: game)
                    .id(game.id)
            }
        }
    }
}

// MARK: - Card view
struct WildGameCardView: View {
    let title: String
    let imageName: String
    let cardBackgroundColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 26/255.0, green: 33/255.0, blue: 63/255.0))

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(14)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
            )

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .tracking(1)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(cardBackgroundColor)
        )
    }
}

// MARK: - Preview
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GameView()
                .environmentObject(ChecklistStore())
        }
    }
}

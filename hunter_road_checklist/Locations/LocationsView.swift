//
//  LocationsView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/26/25.
//

import SwiftUI

struct LocationDefinition: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
}

struct LocationView: View {
    let onLocationCreated: (LocationItem) -> Void

    // MARK: - Colors
    private let backgroundColor = Color(red: 39/255.0, green: 46/255.0, blue: 75/255.0)
    private let cardBackgroundColor = Color(red: 26/255.0, green: 33/255.0, blue: 63/255.0)

    // MARK: - Locations
    private let locations: [LocationDefinition] = [
        LocationDefinition(iconName: "locations_icon_1", title: "FOREST"),
        LocationDefinition(iconName: "locations_icon_2", title: "GRASSLANDS"),
        LocationDefinition(iconName: "locations_icon_3", title: "WETLANDS"),
        LocationDefinition(iconName: "locations_icon_4", title: "MOUNTAINS"),
        LocationDefinition(iconName: "locations_icon_5", title: "RIVERBANKS"),
        LocationDefinition(iconName: "locations_icon_6", title: "PINE THICKETS")
    ]

    init(onLocationCreated: @escaping (LocationItem) -> Void = { _ in }) {
        self.onLocationCreated = onLocationCreated
    }

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
                    // Header with centered title
                    HStack {
                        Spacer()
                    }
                    .frame(height: 44)
                    .overlay(
                        Text("Locations")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white),
                        alignment: .center
                    )
                    .padding(.top, 8)

                    // Grid with location icons
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        ForEach(locations) { location in
                            NavigationLink {
                                LocationCreationView(
                                    tab: .locations,
                                    iconName: location.iconName,
                                    onSave: { newLocation in
                                        onLocationCreated(newLocation)
                                    }
                                )
                            } label: {
                                WildLocationCardView(
                                    title: location.title,
                                    imageName: location.iconName,
                                    cardBackgroundColor: cardBackgroundColor
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
    }
}

// MARK: - Card view
struct WildLocationCardView: View {
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
struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LocationView()
                .dynamicTypeSize(.medium)
        }
    }
}

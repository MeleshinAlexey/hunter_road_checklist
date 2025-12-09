//
//   RootTabView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/24/25.
//

import SwiftUI

enum Tab {
    case checklists
    case inventory
    case game
    case locations
}

struct RootTabView: View {
    @StateObject private var checklistStore = ChecklistStore()
    @State private var selectedTab: Tab = .checklists
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
 
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ChecklistsView(tab: .checklists)
            }
            .environmentObject(checklistStore)
            .tabItem {
                Image(selectedTab == .checklists ? "icon_tabbar_checklists_on" : "icon_tabbar_checklists_off")
                    .renderingMode(.original)
                Text("Checklists")
            }
            .tag(Tab.checklists) 

            NavigationStack {
                ChecklistsView(tab: .inventory)
            }
            .environmentObject(checklistStore)
            .tabItem {
                Image(selectedTab == .inventory ? "icon_tabbar_inventory_on" : "icon_tabbar_inventory_off")
                    .renderingMode(.original)
                Text("Inventory")
            }
            .tag(Tab.inventory)

            NavigationStack {
                ChecklistsView(tab: .game)
            }
            .environmentObject(checklistStore)
            .tabItem {
                Image(selectedTab == .game ? "icon_tabbar_game_on" : "icon_tabbar_game_off")
                    .renderingMode(.original)
                Text("Game")
            }
            .tag(Tab.game)

            NavigationStack {
                ChecklistsView(tab: .locations)
            }
            .environmentObject(checklistStore)
            .tabItem {
                Image(selectedTab == .locations ? "icon_tabbar_locations_on" : "icon_tabbar_locations_off")
                    .renderingMode(.original)
                Text("Locations")
            }
            .tag(Tab.locations)
        }
    }
}


#Preview {
    RootTabView()
        .dynamicTypeSize(.medium)
}

//
//  ContentView.swift
//  Stock Pulse
//
//  Created by Ruwan Thalgahage on 2024-06-07.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

//            FavoritesView()
//                .tabItem {
//                    Label("Favorites", systemImage: "star")
//                }
        }
    }
}

#Preview {
    ContentView()
}

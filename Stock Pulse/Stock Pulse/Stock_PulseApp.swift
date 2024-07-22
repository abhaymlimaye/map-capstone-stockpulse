//
//  Stock_PulseApp.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 18-05-2024.
//

import SwiftUI

@main
struct Stock_PulseApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.theme.colorScheme)
        }
    }
}

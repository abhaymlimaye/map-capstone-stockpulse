//
//  Stock_PulseApp.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 18-05-2024.
//

import SwiftUI

@main
struct Stock_PulseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

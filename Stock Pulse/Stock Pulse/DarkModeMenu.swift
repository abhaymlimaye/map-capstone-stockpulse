//
//  DarkModeMenu.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 21-07-2024.
//
import SwiftUI
import WidgetKit

struct DarkModeMenu: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTheme: String = Theme.automatic.rawValue
    let themes = Theme.allCases.map { $0.rawValue }
    
    var body: some View {
        Menu {
            Picker("Appearance", selection: $selectedTheme) {
                ForEach(themes, id: \.self) { theme in
                    Text(theme)
                        .tag(theme)
                }
            }
            .pickerStyle(.inline)
            .onChange(of: selectedTheme) { newValue in
                if let newTheme = Theme(rawValue: newValue) {
                    themeManager.setTheme(newTheme)
                }
            }
        } label: {
            Label("Appearance", systemImage: "ellipsis.circle")
        }
        .onAppear {
            // Set the initial value of selectedTheme to match the saved theme
            selectedTheme = themeManager.theme.rawValue
        }
    }
}

enum Theme: String, CaseIterable {
    case dark = "Dark"
    case light = "Light"
    case automatic = "Automatic"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .automatic:
            return nil
        }
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") private var selectedTheme = Theme.automatic.rawValue
    @Published var theme: Theme = .automatic
    private let themeKey = "theme"
    
    init() {
        theme = Theme(rawValue: selectedTheme) ?? .automatic
    }
    
    func setTheme(_ theme: Theme) {
        self.theme = theme
        selectedTheme = theme.rawValue
    }
}


#Preview {
    DarkModeMenu()
        .environmentObject(ThemeManager())
}

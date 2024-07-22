//
//  RecommendationSheet.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 21-07-2024.
//

import SwiftUI

struct RecommendationSheet: View {
    var body: some View {
            VStack {
                Text("Device was shaken!")
                    .font(.largeTitle)
                    .padding()
                Button("Dismiss") {
                    // Add code to dismiss the sheet
                }
            }
        }
}

#Preview {
    RecommendationSheet()
}

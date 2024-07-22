//
//  SplashScreenView.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 21-07-2024.
//
import SwiftUI

struct SplashScreenView: View {
    @Binding var showMainView: Bool
    @State private var animationAmount: Double = 1

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Image("StockPulse-Image") // Replace with your splash image
                    .resizable()
                    .frame(width: 160, height: 160)
                    .scaledToFit()
                    .padding()
                    .scaleEffect(animationAmount)
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 1)
                                .repeatCount(3, autoreverses: true)
                        ) {
                            self.animationAmount = 1.2
                        }
                    }
                Text("Stock Pulse").foregroundColor(.black).font(.largeTitle).padding()
                Text("Feel the Market's Heartbeat").foregroundColor(.gray)
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height) // Make VStack take the full screen size
            .background(Color.white)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Adjust the delay as needed
                    // Navigate to the main content view
                    self.showMainView = true
                }
            }
        }
        .edgesIgnoringSafeArea(.all) // Optional: Make the splash screen extend to the safe area edges
    }
}

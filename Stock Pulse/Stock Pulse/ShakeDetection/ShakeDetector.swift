//
//  ShakeDetector.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 21-07-2024.
//

import SwiftUI
import Combine
import UIKit

struct ShakeDetector: ViewModifier {
    @State private var showRecommendationSheet = false
    @State private var shakeNotificationCancellable: AnyCancellable?

    func body(content: Content) -> some View {
        content
            .onAppear {
                shakeNotificationCancellable = NotificationCenter.default.publisher(for: .deviceDidShakeNotification)
                    .sink { _ in
                        showRecommendationSheet = true
                    }
            }
            .onDisappear {
                shakeNotificationCancellable?.cancel()
            }
            .sheet(isPresented: $showRecommendationSheet) {
                RecommendationSheet(show: $showRecommendationSheet).presentationDetents([.medium, .large])
            }
    }
}

extension View {
    func onShake(showRecommendationSheet: Binding<Bool>) -> some View {
        self.modifier(ShakeDetector())
    }
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
        }
    }
}

extension Notification.Name {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}



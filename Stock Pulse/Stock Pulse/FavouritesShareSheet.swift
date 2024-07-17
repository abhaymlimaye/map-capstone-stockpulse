//
//  FavouritesShareSheet.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 17-07-2024.
//

import SwiftUI
import UIKit

struct FavouritesShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


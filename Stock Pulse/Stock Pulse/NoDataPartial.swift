//
//  NoDataPartial.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 08-06-2024.
//

import SwiftUI

struct NoDataPartial: View {
    var show: Bool?
    var retryAction: (() -> Void)?

    var body: some View {
        if let show = show {
            if show {
                Layout(retryAction: retryAction)
            }
        } else {
            Layout(retryAction: retryAction)
        }
    }
}

private struct Layout: View {
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Image(systemName: "network.slash")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.secondary)
                .padding()
            Text("Oops! Data is not available at the moment.")
                .padding()
                .foregroundColor(.secondary)
            if let retryAction = retryAction {
                Button("Retry", systemImage: "arrow.clockwise", action: retryAction)
                    .buttonStyle(.bordered)
                    .padding()
            }
            Spacer()
        }
    }
}


#Preview {
    NoDataPartial(show: true, retryAction: {})
}

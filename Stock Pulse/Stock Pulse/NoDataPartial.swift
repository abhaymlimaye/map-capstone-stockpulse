//
//  NoDataPartial.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 08-06-2024.
//

import SwiftUI

struct NoDataPartial: View {
    var show: Bool?
    
    var body: some View {
        if let show = show {
            if(show) {
                Layout()
            }
        }
        else {
            Layout()
        }
    }
}

private struct Layout: View {
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
            Spacer()
        }
    }
}

#Preview {
    NoDataPartial()
}

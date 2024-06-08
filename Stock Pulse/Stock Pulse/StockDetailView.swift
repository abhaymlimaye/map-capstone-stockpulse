//
//  StockDetailView.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 07-06-2024.
//

import SwiftUI

struct StockDetailView: View {
    let ticker: String
    @StateObject private var viewModel = StockDetailViewModel()

    var body: some View {
        VStack {
            if let stockDetail = viewModel.stockDetail {
                Text(stockDetail.name ?? ticker)
                    .font(.largeTitle)
                    .padding()

                if let logoURL = stockDetail.branding?.logoURL, let url = URL(string: APIEndpoints.appendPolygonApiKey(to: logoURL)) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding()
                    } placeholder: {
                        ProgressView()
                            .frame(width: 100, height: 100)
                    }
                } else {
                    Image("placeholder")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                }

                // Display other details as needed
                Text(stockDetail.description ?? "")
                    .padding()
            } else {
                ProgressView()
                    .onAppear {
                        viewModel.fetchStockDetail(ticker: ticker)
                    }
            }
        }
    }

    
}


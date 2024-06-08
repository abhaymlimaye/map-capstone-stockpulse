//
//  StockDetailView.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 07-06-2024.
//

import SwiftUI

struct StockDetailView: View {
    let ticker: String
    @State private var stockDetail: StockDetail? = nil

    var body: some View {
        VStack {
            if let stockDetail = stockDetail {
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
                        fetchStockDetail()
                    }
            }
        }
    }

    func fetchStockDetail() {
        guard let url = APIEndpoints.polygonUrl(for: ticker) else { return }
        
        print("\n\nStock Detail Url: ", url)

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    print("\nStock Detail Raw Data: ", String(data: data, encoding: .utf8) ?? "NA")
                    let detailResponse = try JSONDecoder().decode(StockDetailResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.stockDetail = detailResponse.results
                        print("\nStock Detail Formatted Data: ", self.stockDetail ?? "NA")
                        print("\nLogo Url: ", APIEndpoints.appendPolygonApiKey(to: self.stockDetail?.branding?.logoURL ?? "NA-"))
                    }
                } catch {
                    print("Error decoding stock detail: \(error)")
                }
            }
        }.resume()
    }
}


//
//  Home.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import SwiftUI

struct Home: View {
    @StateObject private var viewModel = StocksViewModel()
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            Text("Top Movers")
                .font(.largeTitle)
                .padding()

            Picker("Select Tab", selection: $selectedTab) {
                Text("Gainers").tag(0)
                Text("Losers").tag(1)
                Text("Actively Traded").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List {
                if selectedTab == 0 {
                    ForEach(viewModel.gainers) { stock in
                        StockRow(stock: stock)
                    }
                } else if selectedTab == 1 {
                    ForEach(viewModel.losers) { stock in
                        StockRow(stock: stock)
                    }
                } else {
                    ForEach(viewModel.activelyTraded) { stock in
                        StockRow(stock: stock)
                    }
                }
            }
            .onAppear {
                viewModel.fetchTopMovers()
            }
        }
    }
}

struct StockRow: View {
    let stock: Stock

    var body: some View {
        HStack {
            if let url = URL(string: stock.logo) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.trailing, 10)
                } placeholder: {
                    ProgressView()
                        .frame(width: 40, height: 40)
                }
            }

            VStack(alignment: .leading) {
                Text(stock.symbol)
                    .font(.headline)
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(stock.changePercentage)
                .font(.headline)
                .foregroundColor(stock.changePercentage.contains("-") ? .red : .green)
        }
        .padding(.vertical, 5)
    }
}



#Preview {
    Home()
}

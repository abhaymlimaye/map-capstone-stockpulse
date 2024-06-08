//
//  Home.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = StocksViewModel()
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Select Tab", selection: $selectedTab) {
                    Text("Actively Traded").tag(0)
                    Text("Gainers").tag(1)
                    Text("Losers").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List {
                    if selectedTab == 0 {
                        Section("By Highest Volume") {
                            ForEach(viewModel.activelyTraded) { stock in
                                NavigationLink(destination: StockDetailView(ticker: stock.ticker)) {
                                    StockRow(stock: stock)
                                }
                            }
                        }
                    } else if selectedTab == 1 {
                        Section("By Highest Growth") {
                            ForEach(viewModel.gainers) { stock in
                                NavigationLink(destination: StockDetailView(ticker: stock.ticker)) {
                                    StockRow(stock: stock)
                                }
                        }
                    }
                    } else {
                        Section("By Highest Downfall") {
                            ForEach(viewModel.losers) { stock in
                                NavigationLink(destination: StockDetailView(ticker: stock.ticker)) {
                                    StockRow(stock: stock)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Top Movers")
                .onAppear {
                    viewModel.fetchTopMovers()
                }
            }
        }
    }
}

struct StockRow: View {
    let stock: Stock

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.headline)
                Text("Price: \(stock.price)")
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
    HomeView()
}

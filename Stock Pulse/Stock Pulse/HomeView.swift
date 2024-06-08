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
                    Text("Most Traded").tag(0)
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
    let selectedTab = 0

    var body: some View {
      
        HStack {
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.headline)
                HStack {
                    Text("Price:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("$\(stock.price)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Volume:")
                        .foregroundColor(.accentColor)
                        .font(.subheadline)
                    Text(stock.volume)
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(stock.changePercentage)
                    .font(.headline)
                    .foregroundColor(stock.changePercentage.contains("-") ? .red : .green)
                Text("$\(stock.changeAmount)")
                    .font(.subheadline)
                    .foregroundColor(stock.changePercentage.contains("-") ? .red : .green)
            }
            
            Image(systemName: stock.changePercentage.contains("-") ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                .foregroundColor(stock.changePercentage.contains("-") ? .red : .green)
            
        }
        .padding(.vertical, 5)
   
    }
}

#Preview {
    HomeView()
}

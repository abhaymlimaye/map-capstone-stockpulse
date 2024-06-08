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
                        Section("Top 20 By Highest Volume") {
                            ForEach(viewModel.activelyTraded) { stock in
                                NavigationLink(destination: StockDetailView(ticker: stock.ticker)) {
                                    StockRow(stock: stock, selectedTab: selectedTab)
                                }
                            }
                        }
                    } else if selectedTab == 1 {
                        Section("Top 20 By Highest Growth") {
                            ForEach(viewModel.gainers) { stock in
                                NavigationLink(destination: StockDetailView(ticker: stock.ticker)) {
                                    StockRow(stock: stock, selectedTab: selectedTab)
                                }
                        }
                    }
                    } else {
                        Section("Top 20 By Highest Downfall") {
                            ForEach(viewModel.losers) { stock in
                                NavigationLink(destination: StockDetailView(ticker: stock.ticker)) {
                                    StockRow(stock: stock, selectedTab: selectedTab)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Top Movers")
                .navigationBarItems(leading: Text("Discover from the Last Trading Day"), trailing: Image(systemName: selectedTab == 0 ? "chart.line.uptrend.xyaxis" : selectedTab == 1 ? "trophy" : "figure.fall"))
                .onAppear {
                    viewModel.fetchTopMovers()
                }
            }
        }
    }
}

struct StockRow: View {
    let stock: Stock
    let selectedTab: Int

    var body: some View {
      
        HStack {
            VStack(alignment: .leading) {
                Text(stock.ticker)
                    .font(.headline)
                HStack(alignment: .bottom) {
                    Text("Price:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(stock.price)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                HStack(alignment: .bottom) {
                    Text("Volume:")
                        .foregroundColor(.accentColor)
                        .font(selectedTab == 0 ? .subheadline : .caption)
                    Text(stock.volume)
                        .font(selectedTab == 0 ? .headline : .subheadline)
                        .foregroundColor(.accentColor)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(stock.changePercentage)
                    .font(selectedTab != 0 ? .headline : .subheadline)
                    .foregroundColor(stock.changePercentage.contains("-") ? .red : .green)
                Text("$\(stock.changeAmount)")
                    .font(selectedTab != 0 ? .subheadline : .caption)
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

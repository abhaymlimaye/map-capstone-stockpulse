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
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                    else if let activelyTraded = viewModel.activelyTraded, let gainers = viewModel.gainers, let losers = viewModel.losers {
                        if selectedTab == 0 {
                            Section("Top 20 By Highest Volume") {
                                ForEach(activelyTraded) { stock in
                                    NavigationLink(destination: StockDetailView(ticker: stock.ticker ?? "")) {
                                        StockRow(stock: stock, selectedTab: selectedTab)
                                    }
                                }
                            }
                        } 
                        else if selectedTab == 1 {
                            Section("Top 20 By Highest Growth") {
                                ForEach(gainers) { stock in
                                    NavigationLink(destination: StockDetailView(ticker: stock.ticker ?? "")) {
                                        StockRow(stock: stock, selectedTab: selectedTab)
                                    }
                                }
                            }
                        } 
                        else {
                            Section("Top 20 By Highest Downfall") {
                                ForEach(losers) { stock in
                                    NavigationLink(destination: StockDetailView(ticker: stock.ticker ?? "")) {
                                        StockRow(stock: stock, selectedTab: selectedTab)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        NoDataPartial()
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
                Text(stock.ticker ?? "--")
                    .font(.headline)
                HStack(alignment: .bottom) {
                    if let price = stock.price {
                        Text("Price:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(price)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                HStack(alignment: .bottom) {
                    if let volume = stock.volume {
                        Text("Volume:")
                            .foregroundColor(.accentColor)
                            .font(selectedTab == 0 ? .subheadline : .caption)
                        Text(volume)
                            .font(selectedTab == 0 ? .headline : .subheadline)
                            .foregroundColor(.accentColor)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                if let changePercentage = stock.changePercentage, let changeAmount = stock.changeAmount {
                    Text(changePercentage)
                        .font(selectedTab != 0 ? .headline : .subheadline)
                        .foregroundColor(changePercentage.contains("-") ? .red : .green)
                    Text("$\(changeAmount)")
                        .font(selectedTab != 0 ? .subheadline : .caption)
                        .foregroundColor(changePercentage.contains("-") ? .red : .green)
                }
            }
            
            if let changePercentage = stock.changePercentage {
                Image(systemName: changePercentage.contains("-") ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                    .foregroundColor(changePercentage.contains("-") ? .red : .green)
            }
        }
        .padding(.vertical, 5)
   
    }
}

#Preview {
    HomeView()
}

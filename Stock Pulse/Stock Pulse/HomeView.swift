//
//  Home.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = TopStocksViewModel()
    @State private var selectedTab = 0
    
    private let tabs: [Tab<TopStocksViewModel, [Stock]?>] = [
        Tab(tabName: "Most Traded", sectionTitle: "Top 20 By Volume", dataPath: \TopStocksViewModel.activelyTraded),
        Tab(tabName: "Gainers", sectionTitle: "Top 20 By Growth", dataPath: \TopStocksViewModel.gainers),
        Tab(tabName: "Losers", sectionTitle: "Top 20 By Downfall", dataPath: \TopStocksViewModel.losers)
    ]

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                }
                else if let stocks: [Stock] = viewModel[keyPath: tabs[selectedTab].dataPath] {
                    List {
                        Picker("Select Tab", selection: $selectedTab) {
                            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                                Text(tab.tabName).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .listRowBackground(Color.clear) // Set row background to transparent
                        .listRowInsets(EdgeInsets()) // Remove padding

                        Section(tabs[selectedTab].sectionTitle) {
                            ForEach(stocks) { stock in
                                NavigationLink(destination: StockDetailView(ticker: stock.ticker ?? "")) {
                                    StockRow(stock: stock, selectedTab: selectedTab)
                                }
                            }
                        } //section
                    }
                    .animation(.default, value: viewModel[keyPath: tabs[selectedTab].dataPath])
                    .refreshable {
                        viewModel.fetchTopMovers()
                    }//list
                }
                else {
                    NoDataPartial(retryAction: { viewModel.fetchTopMovers() })
                }
            }//vstack
            .navigationTitle("Top Movers")
            .toolbar {
                ToolbarItem(placement: .principal) {Text("")} }
            .navigationBarItems(leading: HStack {
                    Image(systemName: selectedTab == 0 ? "chart.line.uptrend.xyaxis" : selectedTab == 1 ? "trophy" : "figure.fall")
                    Text("From Last Trading Day")},
                trailing: DarkModeMenu())
            .onAppear {
                viewModel.fetchTopMovers()
            }
            .refreshable {
                viewModel.fetchTopMovers()
            }
        }//navigationstack
    }//body
}

struct Tab<Root, Value> {
    let tabName: String
    let sectionTitle: String
    let dataPath: KeyPath<Root, Value>
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

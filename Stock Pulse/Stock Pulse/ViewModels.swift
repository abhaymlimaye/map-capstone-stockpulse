//
//  ViewModels.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import Foundation

class StocksViewModel: ObservableObject {
    @Published var gainers: [Stock] = []
    @Published var losers: [Stock] = []
    @Published var activelyTraded: [Stock] = []

    private let apiUrl = "https://www.alphavantage.co/query?function=TOP_GAINERS_LOSERS&apikey=ELJKR3GKV7GNRLYR"
    private let detailsUrl = "https://api.twelvedata.com/logo?apikey=7ea73364a0ff42b097cf4fc044d4bbfb&symbol="

    func fetchTopMovers() {
        guard let url = URL(string: apiUrl) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    var topMoversResponse = try JSONDecoder().decode(TopMoversResponse.self, from: data)
                    
                    // Sort and filter the top gainers, top losers, and most actively traded lists
                    topMoversResponse.topGainers = Array(
                        topMoversResponse.topGainers
                            .sorted(by: { (a: StockSymbol, b: StockSymbol) in a.changePercentage > b.changePercentage })
                            .prefix(10))
                    topMoversResponse.topLosers = Array(
                        topMoversResponse.topLosers
                            .sorted(by: { (a: StockSymbol, b: StockSymbol) in a.changePercentage > b.changePercentage })
                            .prefix(10))
                    topMoversResponse.mostActivelyTraded = Array(
                        topMoversResponse.mostActivelyTraded
                            .sorted(by: { (a: StockSymbol, b: StockSymbol) in a.changePercentage > b.changePercentage })
                            .prefix(10))
                                    
                    print("\n\nTop Movers:-", topMoversResponse, "\n\n")
                    
                    self.fetchDetails(for: topMoversResponse)
                } catch {
                    print("Error decoding top movers: \(error)")
                }
            }
        }.resume()
    }

    private func fetchDetails(for topMoversResponse: TopMoversResponse) {
        let symbols = topMoversResponse.topGainers + topMoversResponse.topLosers + topMoversResponse.mostActivelyTraded

        let group = DispatchGroup()
        var stocks: [Stock] = []

        for symbol in symbols {
            group.enter()
            guard let url = URL(string: "\(detailsUrl)\(symbol.ticker)") else { return }

            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { group.leave() }
                if let data = data {
                    do {
                        let stockDetail = try JSONDecoder().decode(StockDetail.self, from: data)
                        let companyName = URL(string: stockDetail.logo)?.lastPathComponent.replacingOccurrences(of: ".com", with: "") ?? ""
                        let stock = Stock(symbol: stockDetail.symbol, name: companyName.capitalized, logo: stockDetail.logo, changePercentage: symbol.changePercentage)
                        stocks.append(stock)
                    } catch {
                        print("Error decoding stock detail: \(error)")
                    }
                }
            }.resume()
        }

        // Notify main queue when all detail fetches are completed
        group.notify(queue: .main) {
            // Filter the combined stocks list into the respective categories
            self.gainers = stocks.filter { topMoversResponse.topGainers.map { $0.ticker }.contains($0.symbol) }
            self.losers = stocks.filter { topMoversResponse.topLosers.map { $0.ticker }.contains($0.symbol) }
            self.activelyTraded = stocks.filter { topMoversResponse.mostActivelyTraded.map { $0.ticker }.contains($0.symbol) }
        }
    }

}

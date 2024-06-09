//
//  ViewModels.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import Foundation
import Combine

class StocksViewModel: ObservableObject {
    @Published var gainers: [Stock] = []
    @Published var losers: [Stock] = []
    @Published var activelyTraded: [Stock] = []
    
    func fetchTopMovers() {
        guard let url = APIEndpoints.topMoversUrl() else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                print("\n\nTop Movers Raw Data: ", String(data: data, encoding: .utf8) ?? "NA")
                
                do {
                    let topMoversResponse = try JSONDecoder().decode(TopMoversResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.gainers = topMoversResponse.topGainers
                        self.losers = topMoversResponse.topLosers
                        self.activelyTraded = topMoversResponse.mostActivelyTraded
                    }
                } catch {
                    print("Error decoding top movers: \(error)")
                }
            }
        }.resume()
    }
}

class StockDetailViewModel: ObservableObject {
    @Published var stockDetail: StockDetail? = nil
    @Published var isLoading: Bool = false
    
    func fetchStockDetail(ticker: String) {
        guard let url = APIEndpoints.polygonUrl(for: ticker) else { return }
        
        isLoading = true
        
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
                    
                    self.isLoading = false
                } catch {
                    print("Error decoding stock detail: \(error)")
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

class SymbolSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [SymbolSearchResult] = []

    private let apiKey = "demo"

    func search() {
        guard !searchText.isEmpty else { return }
        
        guard let url = APIEndpoints.symbolSearchUrl(for: searchText) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode(SymbolSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.results = response.bestMatches.filter { !$0.symbol.contains(".") }
                }
            } catch {
                print("Error decoding response: \(error)")
            }
        }
        
        task.resume()
    }
}

class ResultRowViewModel: ObservableObject {
    @Published var iconURL: String?
    private var cancellable: AnyCancellable?
    
    func fetchIcon(for symbol: String) {
        iconURL = nil //resetting previous Icon until new one is available
        
        guard let url = APIEndpoints.logoUrl(symbol: symbol) else {
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: IconResponse.self, decoder: JSONDecoder())
            .map { $0.url }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] url in
                self?.iconURL = url
            })
    }
}

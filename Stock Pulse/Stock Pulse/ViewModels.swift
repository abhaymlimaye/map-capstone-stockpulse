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

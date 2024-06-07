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

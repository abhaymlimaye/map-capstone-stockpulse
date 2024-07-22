//
//  ViewModels.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import Foundation
import Combine
import WidgetKit

class TopStocksViewModel: ObservableObject {
    @Published var gainers: [Stock]? = nil
    @Published var losers: [Stock]? = nil
    @Published var activelyTraded: [Stock]? = nil
    
    @Published var isLoading: Bool = false
    
    @Published var bestStock: Stock? = nil
    @Published var worstStock: Stock? = nil
    
    func fetchTopMovers(completion: (() -> Void)? = nil) {
        guard let url = APIEndpoints.topMoversUrl() else { return }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                print("\n\nTop Movers Raw Data: ", String(data: data, encoding: .utf8) ?? "NA")
                
                do {
                    let topMoversResponse = try JSONDecoder().decode(TopMoversResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.gainers = topMoversResponse.topGainers
                        self.losers = topMoversResponse.topLosers
                        self.activelyTraded = topMoversResponse.mostActivelyTraded
                        self.isLoading = false
                        completion?()
                    }
                } catch {
                    print("Error decoding top movers: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion?()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion?()
                }
            }
        }.resume()
    }
    
    func getRecommendation() {
        fetchTopMovers { [weak self] in
            guard let self = self else { return }
            guard let gainers = self.gainers, let losers = self.losers, let activelyTraded = self.activelyTraded else {
                print("\n\nFailed to Get Recommendations - No data received from fetchTopMovers")
                return
            }
            
            // Combine gainers and actively traded lists to find the best stock with highest volume
            let combinedGainers = gainers + activelyTraded
            self.bestStock = combinedGainers.max {
                guard let change1 = Double($0.changePercentage ?? ""), let volume1 = Double($0.volume ?? ""),
                      let change2 = Double($1.changePercentage ?? ""), let volume2 = Double($1.volume ?? "") else { return false }
                return (change1 < change2) || (change1 == change2 && volume1 < volume2)
            }
            
            // Combine losers and actively traded lists to find the worst stock with lowest volume
            let combinedLosers = losers + activelyTraded
            self.worstStock = combinedLosers.min {
                guard let change1 = Double($0.changePercentage ?? ""), let volume1 = Double($0.volume ?? ""),
                      let change2 = Double($1.changePercentage ?? ""), let volume2 = Double($1.volume ?? "") else { return false }
                return (change1 > change2) || (change1 == change2 && volume1 > volume2)
            }
        }
    }
}

class StockDetailViewModel: ObservableObject {
    @Published var stockDetail: StockDetail? = nil
    @Published var isLoading: Bool = false
    
    func fetchStockDetail(ticker: String) {
        guard let url = APIEndpoints.polygonUrl(for: ticker) else { return }
        
        self.isLoading = true
        stockDetail = nil
        
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
                        self.isLoading = false
                    }
                } catch {
                    print("Error decoding stock detail: \(error)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
}


class SymbolSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [SymbolSearchResult]? = nil
    @Published var isLoading: Bool = false

    private let apiKey = "demo"

    func search() {
        guard !searchText.isEmpty else { return }
        
        guard let url = APIEndpoints.symbolSearchUrl(for: searchText) else { return }
        
        self.isLoading = true
        self.results = nil
  
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(SymbolSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.results = response.bestMatches.filter { !$0.symbol.contains(".") }
                    self.isLoading = false
                }
            } catch {
                print("Error decoding response: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
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

class FavoritesViewModel: ObservableObject {
    static let shared = FavoritesViewModel()

    @Published var favorites: [FavoriteStock] = []
    var favoritesAsString: String {    // Computed property for formatted favorites list for sharing
        favorites.map { "\($0.name) (\($0.ticker))" }.joined(separator: "\n")
    }
    
    private let userDefaultsKey = "favorites"
    private let suiteName = "com.example.s2g3.Stock-Pulse"

    private init() {
        loadFavorites()
    }

    func addFavorite(stock: FavoriteStock) {
        guard !favorites.contains(where: { $0.ticker == stock.ticker }) else { return }
        favorites.append(stock)
        saveFavorites()
    }

    func removeFavorite(symbol: String) {
        favorites.removeAll { $0.ticker == symbol }
        saveFavorites()
    }
    
    func moveFavorite(from source: IndexSet, to destination: Int) {
       favorites.move(fromOffsets: source, toOffset: destination)
       saveFavorites()
   }

    func isFavorite(symbol: String) -> Bool {
        return favorites.contains { $0.ticker == symbol }
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.shared.set(encoded, forKey: userDefaultsKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func loadFavorites() {
        if let savedFavorites = UserDefaults.shared.data(forKey: userDefaultsKey),
           let decodedFavorites = try? JSONDecoder().decode([FavoriteStock].self, from: savedFavorites) {
            favorites = decodedFavorites
        }
    }
}
extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.example.s2g3.Stock-Pulse")!
}

class TimeSeriesViewModel: ObservableObject {
    let timeSeriesMode: TimeSeriesMode
    
    init(timeSeriesMode: TimeSeriesMode) {
        self.timeSeriesMode = timeSeriesMode
        
        switch(timeSeriesMode) {
            case .recent:
                self.dateTimeFormat = "yyyy-MM-dd HH:mm:ss"
                self.additionalUrlParams = [URLQueryItem(name: "date", value: "today")]
                self.outputsize = 10
                break
            case .historical:
                self.dateTimeFormat = "yyyy-MM-dd"
                self.outputsize = 30
                break
        }
    }
    
    private var dateTimeFormat: String
    private var additionalUrlParams: [URLQueryItem]?
    private var outputsize: Int
    
    @Published var timeSeriesValues: [ConvertedTimeSeriesValue]? = nil
    @Published var isLoading: Bool = false
    
   
    private var cancellables = Set<AnyCancellable>()

    func fetchTimeSeries(symbol: String, interval: Interval) {
        guard let url = APIEndpoints.timeseriesUrl(symbol: symbol, interval: interval.rawValue, outputsize: outputsize, additionalParams: additionalUrlParams) else {
            print("Invalid Time Series URL")
            return
        }
        
        print("\n\nTime Series URL: ", url)
        isLoading = true
        timeSeriesValues = nil

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: TimeSeriesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    print("Error fetching data: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                print("\nTime Series Response:-\n", response.values, "\n\n")
                self?.timeSeriesValues = self?.getConvertedData(from: response.values)
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func getConvertedData(from data: [TimeSeriesValue]) -> [ConvertedTimeSeriesValue]? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateTimeFormat
        
        return data.compactMap { value in
            guard
                let date = formatter.date(from: value.datetime),
                let open = Double(value.open),
                let high = Double(value.high),
                let low = Double(value.low),
                let close = Double(value.close),
                let volume = Int(value.volume)
            else {
                return nil
            }

            return ConvertedTimeSeriesValue(
                datetime: date,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume
            )
        }
    }
}

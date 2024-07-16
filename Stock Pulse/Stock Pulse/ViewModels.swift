//
//  ViewModels.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import Foundation
import Combine

class StocksViewModel: ObservableObject {
    @Published var gainers: [Stock]? = nil
    @Published var losers: [Stock]? = nil
    @Published var activelyTraded: [Stock]? = nil
    @Published var isLoading: Bool = false
    
    func fetchTopMovers() {
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
                    }
                } catch {
                    print("Error decoding top movers: \(error)")
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
    private let userDefaultsKey = "favorites"

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
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadFavorites() {
        if let savedFavorites = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedFavorites = try? JSONDecoder().decode([FavoriteStock].self, from: savedFavorites) {
            favorites = decodedFavorites
        }
    }
}

class TimeSeriesViewModel: ObservableObject {
    var dateTimeFormat: String
    
    init(dateTimeFormat: String) {
        self.dateTimeFormat = dateTimeFormat
    }
    
    @Published var timeSeriesValues: [ConvertedTimeSeriesValue]? = nil
    @Published var isLoading: Bool = false
    
    static let outputsize = 20
    private var cancellables = Set<AnyCancellable>()

    func fetchTimeSeries(symbol: String, interval: String) {
        guard let url = APIEndpoints.timeseriesUrl(symbol: symbol, interval: interval, outputsize: TimeSeriesViewModel.outputsize) else {
            print("Invalid Time Series URL")
            return
        }
        
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

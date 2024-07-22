//
//  Track_Favorites.swift
//  Track Favorites
//
//  Created by Abhay Limaye on 17-07-2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private var widgetViewModel = WidgetViewModel()

    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), favorites: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        widgetViewModel.loadFavoritesWithPrices { favorites in
            let entry = WidgetEntry(date: Date(), favorites: favorites)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        widgetViewModel.loadFavoritesWithPrices { favorites in
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
            let entry = WidgetEntry(date: currentDate, favorites: favorites)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

class WidgetViewModel {
    private let userDefaultsKey = "favorites"
    private let apiKey = "7ea73364a0ff42b097cf4fc044d4bbfb"

    func loadFavoritesWithPrices(completion: @escaping ([FavoriteStock]) -> Void) {
        guard let savedFavorites = UserDefaults.shared.data(forKey: userDefaultsKey),
              var favorites = try? JSONDecoder().decode([FavoriteStock].self, from: savedFavorites) else {
            print("From Widget - No Favorites Found")
            completion([])
            return
        }

        let dispatchGroup = DispatchGroup()
        for index in 0..<3 {
            dispatchGroup.enter()
            fetchStockPrice(symbol: favorites[index].ticker) { price in
                if let price = price {
                    favorites[index].price = price
                    
                    print("----\(favorites[index].ticker): $\(price)")
                    
                    if let encoded = try? JSONEncoder().encode(favorites) {
                        UserDefaults.shared.set(encoded, forKey: self.userDefaultsKey)
                    }
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(favorites)
        }
    }

    private func fetchStockPrice(symbol: String, completion: @escaping (Double?) -> Void) {
        guard let url = URL(string: "https://api.twelvedata.com/price?symbol=\(symbol)&apikey=\(apiKey)") else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let realtimePrice = try? JSONDecoder().decode(RealtimePrice.self, from: data),
                  let price = Double(realtimePrice.price) else {
                completion(nil)
                return
            }
            completion(price)
        }
        task.resume()
    }
}

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.example.s2g3.Stock-Pulse")!
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let favorites: [FavoriteStock]
}

struct FavoriteStock: Codable, Identifiable {
    var id: String { ticker }
    var name: String
    var ticker: String
    var price: Double?
}

struct RealtimePrice: Codable {
    let price: String
}

struct WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            if entry.favorites.isEmpty {
                Text("Add some Favorite Stocks to Monitor.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } 
            else {
                ForEach(entry.favorites.prefix(3).enumerated().map { $0 }, id: \.element.id) { index, stock in
                    StockRowView(stock: stock)
                    if index < 2 { Divider() }
                }
            }
        }//vstack
    }
}

struct StockRowView: View {
    var stock: FavoriteStock

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(stock.ticker).font(.subheadline)
                Spacer()
                if let price = stock.price {
                    Text("$" + String(format: "%.2f", price)).font(.headline).foregroundColor(.accentColor)
                }
                else {
                    Image(systemName: "clock")
                }
            }
            Text(stock.name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct Track_Favorites: Widget {
    let kind: String = "Track_Favorites"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Track Favorites Widget")
        .description("Track the Realtime Prices of your Favorite Stocks.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

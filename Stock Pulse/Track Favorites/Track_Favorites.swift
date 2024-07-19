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
    var favoriteStocksWithPrices: [FavoriteStockWithPrice] = []
    private let userDefaultsKey = "favorites"
    
    func loadFavoritesWithPrices(completion: @escaping ([FavoriteStockWithPrice]) -> Void) {
        guard let savedFavorites = UserDefaults.shared.data(forKey: userDefaultsKey),
              let decodedFavorites = try? JSONDecoder().decode([FavoriteStock].self, from: savedFavorites) else {
            print("From Widget - No Favorites Found")
            completion([])
            return
        }
        
        var fetchedFavorites: [FavoriteStockWithPrice] = []
        let dispatchGroup = DispatchGroup()
        
        for favorite in decodedFavorites.prefix(3) {
            dispatchGroup.enter()
            fetchStockPrice(symbol: favorite.ticker) { price in
                if let price = price {
                    let favoriteWithPrice = FavoriteStockWithPrice(
                        name: favorite.name,
                        ticker: favorite.ticker,
                        price: price
                    )
                    fetchedFavorites.append(favoriteWithPrice)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("From Widget - Favorites with Price:- \n \(fetchedFavorites)")
            completion(fetchedFavorites)
        }
    }

    private func fetchStockPrice(symbol: String, completion: @escaping (Double?) -> Void) {
        guard let url = URL(string: "https://api.twelvedata.com/price?symbol=\(symbol)&apikey=7ea73364a0ff42b097cf4fc044d4bbfb") else {
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
    let favorites: [FavoriteStockWithPrice]
}
struct FavoriteStock: Codable, Identifiable {
    var id: String { ticker }
    var name: String
    var ticker: String
}
struct RealtimePrice: Codable {
    let price: String
}
struct FavoriteStockWithPrice: Identifiable {
    var id: String { ticker }
    var name: String
    var ticker: String
    var price: Double
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
                ForEach(entry.favorites.enumerated().map { $0 }, id: \.element.id) { index, stock in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(stock.ticker).font(.subheadline)
                            Spacer()
                            Text("$" + String(format: "%.2f", stock.price))
                                .font(.headline)
                                .foregroundColor(.accentColor)
                        }
                        Text(stock.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if index != entry.favorites.count - 1 {
                            Divider()
                        }
                    }
                }//foreach
            }//else
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




//
//  Home.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import SwiftUI
import Combine

// Image Cache
class ImageCache {
    static let shared = ImageCache()
    private init() {}
    
    private var cache = NSCache<NSString, UIImage>()
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

// Custom Async Image View
struct AsyncImageView: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Image

    init(url: String, placeholder: Image = Image(systemName: "photo")) {
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        if let image = loader.image {
            Image(uiImage: image)
                .resizable()
        } else {
            placeholder
                .onAppear {
                    loader.load()
                }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private let url: String
    private var cancellable: AnyCancellable?

    init(url: String) {
        self.url = url
    }

    deinit {
        cancellable?.cancel()
    }

    func load() {
        if let cachedImage = ImageCache.shared.getImage(forKey: url) {
            self.image = cachedImage
            return
        }

        guard let url = URL(string: url) else { return }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self, let image = $0 else { return }
                ImageCache.shared.setImage(image, forKey: self.url)
                self.image = image
            }
    }
}

// Stock Row View
struct StockRow: View {
    let stock: Stock

    var body: some View {
        HStack {
            AsyncImageView(url: stock.logo)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .padding(.trailing, 10)

            VStack(alignment: .leading) {
                Text(stock.symbol)
                    .font(.headline)
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(stock.changePercentage)
                .font(.headline)
                .foregroundColor(stock.changePercentage.contains("-") ? .red : .green)
        }
        .padding(.vertical, 5)
    }
}

// Home View
struct Home: View {
    @StateObject private var viewModel = StocksViewModel()
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            Text("Top Movers")
                .font(.largeTitle)
                .padding()

            Picker("Select Tab", selection: $selectedTab) {
                Text("Gainers").tag(0)
                Text("Losers").tag(1)
                Text("Actively Traded").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List {
                if selectedTab == 0 {
                    ForEach(viewModel.gainers) { stock in
                        StockRow(stock: stock)
                    }
                } else if selectedTab == 1 {
                    ForEach(viewModel.losers) { stock in
                        StockRow(stock: stock)
                    }
                } else {
                    ForEach(viewModel.activelyTraded) { stock in
                        StockRow(stock: stock)
                    }
                }
            }
            .onAppear {
                viewModel.fetchTopMovers()
            }
        }
    }
}

// Preview
#Preview {
    Home()
}

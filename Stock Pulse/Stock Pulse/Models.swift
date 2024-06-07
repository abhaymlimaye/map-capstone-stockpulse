//
//  Models.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import Foundation
import SwiftUI

struct TopMoversResponse: Codable {
    let topGainers: [StockSymbol]
    let topLosers: [StockSymbol]
    let mostActivelyTraded: [StockSymbol]
    
    enum CodingKeys: String, CodingKey {
        case topGainers = "top_gainers"
        case topLosers = "top_losers"
        case mostActivelyTraded = "most_actively_traded"
    }
}

struct StockSymbol: Codable {
    let ticker: String
    let price: String
    let changeAmount: String
    let changePercentage: String
    let volume: String
    
    enum CodingKeys: String, CodingKey {
        case ticker, price
        case changeAmount = "change_amount"
        case changePercentage = "change_percentage"
        case volume
    }
}

struct StockDetail: Decodable {
    let symbol: String
    let logo: String

    enum CodingKeys: String, CodingKey {
        case meta
        case url
    }

    enum MetaKeys: String, CodingKey {
        case symbol
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let metaContainer = try container.nestedContainer(keyedBy: MetaKeys.self, forKey: .meta)
        symbol = try metaContainer.decode(String.self, forKey: .symbol)
        logo = try container.decode(String.self, forKey: .url)
    }
}


struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let logo: String
    let changePercentage: String
}

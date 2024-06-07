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

struct StockDetail: Codable {
    let symbol: String
    let logo: String
    
    var name: String {
        return URL(string: logo)?
            .lastPathComponent
            .components(separatedBy: ".")
            .first?
            .capitalized ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case symbol = "meta.symbol"
        case logo = "url"
    }
}

struct Stock: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let logo: String
    let changePercentage: String
}

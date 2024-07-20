//
//  Models.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import Foundation
import SwiftUI

struct TopMoversResponse: Codable {
    var topGainers: [Stock]?
    var topLosers: [Stock]?
    var mostActivelyTraded: [Stock]?
    
    enum CodingKeys: String, CodingKey {
        case topGainers = "top_gainers"
        case topLosers = "top_losers"
        case mostActivelyTraded = "most_actively_traded"
    }
}

struct Stock: Identifiable, Codable, Equatable {
    let id = UUID()
    let ticker: String?
    let price: String?
    let changePercentage: String?
    let changeAmount: String?
    let volume: String?
    
    enum CodingKeys: String, CodingKey {
        case ticker = "ticker"
        case price = "price"
        case changePercentage = "change_percentage"
        case volume
        case changeAmount = "change_amount"
    }
}

struct StockDetail: Codable {
    let ticker: String?
        let name: String?
        let market: String?
        let locale: String?
        let primaryExchange: String?
        let type: String?
        let active: Bool?
        let currencyName: String?
        let cik: String?
        let compositeFigi: String?
        let phoneNumber: String?
        let address: Address?
        let description: String?
        let sicCode: String?
        let sicDescription: String?
        let tickerRoot: String?
        let tickerSuffix: String?
        let listDate: String?
        let roundLot: Int64?
        let homepageURL: String?
        let totalEmployees: Int64?
        let marketCap: Double?
        let branding: Branding?
        let shareClassSharesOutstanding: UInt64?
        let weightedSharesOutstanding: UInt64?

        enum CodingKeys: String, CodingKey {
            case ticker
            case name
            case market
            case locale
            case primaryExchange = "primary_exchange"
            case type
            case active
            case currencyName = "currency_name"
            case cik
            case compositeFigi = "composite_figi"
            case phoneNumber = "phone_number"
            case address
            case description
            case sicCode = "sic_code"
            case sicDescription = "sic_description"
            case tickerRoot = "ticker_root"
            case tickerSuffix = "ticker_suffix"
            case listDate = "list_date"
            case roundLot = "round_lot"
            case homepageURL = "homepage_url"
            case totalEmployees = "total_employees"
            case marketCap = "market_cap"
            case branding
            case shareClassSharesOutstanding = "share_class_shares_outstanding"
            case weightedSharesOutstanding = "weighted_shares_outstanding"
        }
}
struct Branding: Codable {
    let logoURL: String?

    enum CodingKeys: String, CodingKey {
        case logoURL = "icon_url"
    }
}
struct Address: Codable {
    let address1: String?
    let address2: String?
    let city: String?
    let state: String?
    let postalCode: String?

    enum CodingKeys: String, CodingKey {
        case address1
        case address2
        case city
        case state
        case postalCode = "postal_code"
    }
}
struct StockDetailResponse: Codable {
    let results: StockDetail
}

struct SymbolSearchResponse: Codable {
    let bestMatches: [SymbolSearchResult]
}

struct SymbolSearchResult: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
    }
}
struct IconResponse: Decodable {
    let url: String
}

struct FavoriteStock: Codable, Identifiable {
    var id: String { ticker }
    var name: String
    var ticker: String
    var price: Double?
}


struct TimeSeriesResponse: Codable {
    let values: [TimeSeriesValue]
}
struct TimeSeriesValue: Codable, Identifiable {
    var id: String { datetime }
    let datetime: String
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
}
struct ConvertedTimeSeriesValue: Identifiable {
    var id = UUID()
    var datetime: Date
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var volume: Int
}

enum TimeSeriesMode {
    case recent
    case historical
}

enum Interval: String, CaseIterable {
    case oneMin = "1min"
    case fiveMin = "5min"
    case fifteenMin = "15min"
    case thirtyMin = "30min"
    case fortyFiveMin = "45min"
    case oneHour = "1h"
    
    case oneDay = "1day"
    case oneWeek = "1week"
    case oneMonth = "1month"
    
    static var recentIntervals: [Interval] {
        return [.oneMin, .fiveMin, .fifteenMin, .thirtyMin, .fortyFiveMin, .oneHour]
    }
    
    static var historicalIntervals: [Interval] {
        return [.oneDay, .oneWeek, .oneMonth]
    }
}



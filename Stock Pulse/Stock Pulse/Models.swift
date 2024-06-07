//
//  Models.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 06-06-2024.
//

import Foundation
import SwiftUI

struct TopMoversResponse: Codable {
    var topGainers: [Stock]
    var topLosers: [Stock]
    var mostActivelyTraded: [Stock]
    
    enum CodingKeys: String, CodingKey {
        case topGainers = "top_gainers"
        case topLosers = "top_losers"
        case mostActivelyTraded = "most_actively_traded"
    }
}

//struct PolygonStockDetail: Decodable {
//    struct Branding: Decodable {
//        let logo_url: String
//    }
//    
//    struct Results: Decodable {
//        let name: String
//        let branding: Branding
//    }
//    
//    let results: Results
//}

struct Stock: Identifiable, Codable {
    let id = UUID()
    let ticker: String
    let price: String
    let changePercentage: String
    
    enum CodingKeys: String, CodingKey {
        case ticker = "ticker"
        case price = "price"
        case changePercentage = "change_percentage"
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
        let roundLot: Int?
        let homepageURL: String?
        let totalEmployees: Int?
        let branding: Branding?
        let shareClassSharesOutstanding: Int?

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
            case branding
            case shareClassSharesOutstanding = "share_class_shares_outstanding"
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


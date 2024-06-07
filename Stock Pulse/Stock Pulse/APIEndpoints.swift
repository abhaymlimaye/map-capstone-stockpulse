//
//  APIEndpoints.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 07-06-2024.
//

import Foundation

struct APIEndpoints {
    private static let apiKeyAlphaVantage = "ELJKR3GKV7GNRLYR"
    private static let apiKeysPolygon = [
        "R5la5_1NOCFkCrBSa6fcLshlx10asi7T",
        "Jep6dAWBIj9EmMCV40FKxZ_A4Kmiuph0",
        "7Npa6OFOP_2r3FON61oNOwPDglMEpAGz"
    ]
    
    private static let topMoversBaseUrl = "https://www.alphavantage.co/query"
    private static let polygonBaseUrl = "https://api.polygon.io/v3"
    private static let polygonTickerEndpoint = "/reference/tickers"

    private static func getRandomPolygonApiKey() -> String {
        return apiKeysPolygon.randomElement() ?? apiKeysPolygon[0]
    }

    static func topMoversUrl() -> URL? {
        var components = URLComponents(string: topMoversBaseUrl)
        components?.queryItems = [
            URLQueryItem(name: "function", value: "TOP_GAINERS_LOSERS"),
            URLQueryItem(name: "apikey", value: apiKeyAlphaVantage)
        ]
        return components?.url
    }

    static func polygonUrl(for symbol: String) -> URL? {
        var components = URLComponents(string: "\(polygonBaseUrl)\(polygonTickerEndpoint)/\(symbol)")
        components?.queryItems = [
            URLQueryItem(name: "apiKey", value: getRandomPolygonApiKey())
        ]
        return components?.url
    }
    
    static func appendPolygonApiKey(to url: String) -> String {
        let apiKey = getRandomPolygonApiKey()
        return "\(url)?apiKey=\(apiKey)"
    }
}




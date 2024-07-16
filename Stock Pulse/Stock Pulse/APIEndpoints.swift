//
//  APIEndpoints.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 07-06-2024.
//

import Foundation

struct APIEndpoints {
    private static let apiKeyAlphaVantage = [
        "ELJKR3GKV7GNRLYR",
        "0TMQATF9UEX595QM",
        "G2XUVREOY1QCVG1E",
        "8SJQ47RT5UECSX9E",
        "TPKFXXIHP0RRW91I",
        "BDHG82F3PSQF3AXQ"
    ]
    private static let apiKeysPolygon = [
        "R5la5_1NOCFkCrBSa6fcLshlx10asi7T",
        "Jep6dAWBIj9EmMCV40FKxZ_A4Kmiuph0",
        "7Npa6OFOP_2r3FON61oNOwPDglMEpAGz",
        "DDEZ_x3FduU8Q57rDAdo4zPBoSsIri2P",
        "xClmupp2psdxMR4GX3FmFxuWhrfIR4VO"
    ]
    private static let apiKeysTwelvedata = [
        "7ea73364a0ff42b097cf4fc044d4bbfb"
    ]
    
    private static let alphavantageBaseUrl = "https://www.alphavantage.co/query"
    private static let polygonBaseUrl = "https://api.polygon.io/v3"
    private static let polygonTickerEndpoint = "/reference/tickers"
    private static let twelvedataBaseUrl = "https://api.twelvedata.com"
    private static let twelvedataLogoEndpoint = "/logo"
    private static let twelevedataTimeseriesEndpoint = "/time_series"

    private static func getRandomApiKey(from keyList: [String]) -> String {
        return keyList.randomElement() ?? keyList[0]
    }

    static func topMoversUrl() -> URL? {
        var components = URLComponents(string: alphavantageBaseUrl)
        components?.queryItems = [
            URLQueryItem(name: "function", value: "TOP_GAINERS_LOSERS"),
            URLQueryItem(name: "apikey", value: getRandomApiKey(from: apiKeyAlphaVantage))
        ]
        return components?.url
    }

    static func polygonUrl(for symbol: String) -> URL? {
        var components = URLComponents(string: "\(polygonBaseUrl)\(polygonTickerEndpoint)/\(symbol)")
        components?.queryItems = [
            URLQueryItem(name: "apiKey", value: getRandomApiKey(from: apiKeysPolygon))
        ]
        return components?.url
    }
    
    static func appendPolygonApiKey(to url: String) -> String {
        let apiKey = getRandomApiKey(from: apiKeysPolygon)
        return "\(url)?apiKey=\(apiKey)"
    }
    
    static func symbolSearchUrl(for keywords: String) -> URL? {
        var components = URLComponents(string: alphavantageBaseUrl)
        components?.queryItems = [
            URLQueryItem(name: "function", value: "SYMBOL_SEARCH"),
            URLQueryItem(name: "apikey", value: getRandomApiKey(from: apiKeyAlphaVantage)),
            URLQueryItem(name: "keywords", value: keywords)
        ]
        return components?.url
    }
    
    static func logoUrl(symbol: String) -> URL? {
        var components = URLComponents(string: "\(twelvedataBaseUrl)\(twelvedataLogoEndpoint)")
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: getRandomApiKey(from: apiKeysTwelvedata))
        ]
        return components?.url
    }
    
    static func timeseriesUrl(symbol: String, interval: String, outputsize: Int, additionalParams: [URLQueryItem]?) -> URL? {
        var components = URLComponents(string: twelvedataBaseUrl + twelevedataTimeseriesEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "apikey", value: getRandomApiKey(from: apiKeysTwelvedata)),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "interval", value: interval),
            URLQueryItem(name: "outputsize", value: String(outputsize))
        ]
        
        if let additionalParams = additionalParams {
            components?.queryItems?.append(contentsOf: additionalParams)
        }
        
        return components?.url
    }
}




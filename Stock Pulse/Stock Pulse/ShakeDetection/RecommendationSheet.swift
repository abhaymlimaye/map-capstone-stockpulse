//
//  RecommendationSheet.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 21-07-2024.
//

import SwiftUI

struct RecommendationSheet: View {
    @ObservedObject var viewModel = TopStocksViewModel()
    @Binding var show: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                //Loading
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                }
                //Data
                else if let bestStock = viewModel.bestStock, let worstStock = viewModel.worstStock {
                    HStack {
                        Image(systemName: "flame").foregroundColor(.green)
                        Text("Hot Pick").font(.title2).foregroundColor(.green)
                        Spacer()
                    }
                    HStack {
                        //Image(systemName: "flame").foregroundColor(.secondary)
                        Text("Rising star with strong potential").font(.caption).foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    NavigationLink(destination: StockDetailView(ticker: bestStock.ticker ?? "")) {
                        StockRow(stock: bestStock, selectedTab: 1)
                    }.padding(.top)
                    
                    Divider().padding(.vertical)
      
                    HStack {
                        Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
                        Text("Caution Zone").font(.title2).foregroundColor(.red)
                        Spacer()
                    }
                    HStack {
                        //Image(systemName: "flame").foregroundColor(.secondary)
                        Text("High risk, proceed with care").font(.caption).foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    NavigationLink(destination: StockDetailView(ticker: worstStock.ticker ?? "")) {
                        StockRow(stock: worstStock, selectedTab: 2)
                    }.padding(.top)
                }
                //No Data
                else {
                    NoDataPartial()
                }
                
                Spacer()
            }//vstack
            .navigationTitle("Our Recommendation")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Image(systemName: "wand.and.rays"),
                                trailing: Button("", systemImage: "xmark", action: { show = false }) )
            .padding()
            .onAppear{ viewModel.getRecommendation() }
        }//navigation view
    }
}

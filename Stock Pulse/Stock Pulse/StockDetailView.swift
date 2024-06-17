//
//  StockDetailView.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 07-06-2024.
//

import SwiftUI

struct StockDetailView: View {
    let ticker: String
    @StateObject private var viewModel = StockDetailViewModel()
    @ObservedObject var favouritesViewModel = FavoritesViewModel.shared
    @State var showGraphs = false

    var body: some View {
            VStack() {
                if viewModel.isLoading { //loading
                    ProgressView()
                        .padding()
                }
                else if let stockDetail = viewModel.stockDetail { //details data
                    ScrollView {
                        HStack(alignment: .center) {
                            if let logoURL = stockDetail.branding?.logoURL, let url = URL(string: APIEndpoints.appendPolygonApiKey(to: logoURL)) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .padding(.trailing)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                }
                            } //logo
                            
                            //symbol, name, charts button and website
                            VStack(alignment: .leading){
                                //name
                                Text(stockDetail.name ?? ticker)
                                    .font(.title2)
                                
                                //symbol
                                Text(ticker)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom)
                                
                                HStack(alignment: .center){
                                    //charts button
                                    Button(" Charts", systemImage: "chart.xyaxis.line", action: {
                                        showGraphs = true
                                    })
                                    .buttonStyle(.borderedProminent)
                            
                                    //Spacer()
                                    
                                    //website
                                    if let homepageURL = stockDetail.homepageURL, let url = URL(string: homepageURL) {
                                        Link(destination: url) {
                                            Image(systemName: "safari")
                                            Text("Website")
                                        }
                                        .buttonStyle(.bordered)
                                        //.font(.subheadline)
                                    }
                                }
                            }
                        } //hstack
                        .padding()
        
                        //description
                        Text(stockDetail.description ?? "")
                            .padding()
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]){
                            if let market = stockDetail.market {
                                MetricTile(icon: "storefront", label: "Market", value: market.capitalized)
                            }
                            
                            if let primaryExchange = stockDetail.primaryExchange {
                                MetricTile(icon: "arrow.left.arrow.right", label: "Exchange", value: primaryExchange + " " + (stockDetail.locale ?? "").uppercased())
                            }
                            
                            if let type = stockDetail.type {
                                MetricTile(icon: "rectangle.3.group", label: "Type", value: type)
                            }
                            
                            if let listDate = stockDetail.listDate {
                                MetricTile(icon: "calendar", label: "List Date", value: listDate)
                            }
                            
                            if let cik = stockDetail.cik {
                                MetricTile(icon: "number.square", label: "CIK#", value: cik)
                            }
                            
                            if let currencyName = stockDetail.currencyName {
                                MetricTile(icon: "banknote", label: "Currency", value: currencyName.uppercased())
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible())]) {
                            if let sicDescription = stockDetail.sicDescription {
                                MetricTile(icon: "building.2", label: "SIC Description", value: sicDescription.capitalized)
                            }
                            
                            if let marketCap = stockDetail.marketCap {
                                MetricTile(icon: "chart.pie", label: "Market Cap", value: String(marketCap))
                            }
                            
                            if let weightedSharesOutstanding = stockDetail.weightedSharesOutstanding, let shareClassSharesOutstanding = stockDetail.shareClassSharesOutstanding {
                                MetricTile(icon: "hourglass.tophalf.filled", label: "Weighted / Class Outstanding Shares", value: String(weightedSharesOutstanding) + " / " + String(shareClassSharesOutstanding))
                            }
                           
                            if let compositeFigi = stockDetail.compositeFigi {
                                MetricTile(icon: "globe.americas", label: "Composite FIGI", value: compositeFigi)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        //graphs
                        .sheet(isPresented: $showGraphs, content: {
                            StockGraphsView(stockDetail: stockDetail, show: $showGraphs).presentationDetents([.medium, .large])
                        })
                    } //scrollview
                } //end details data
                else { //failure case
                    NoDataPartial(show: !viewModel.isLoading)
                }
            } //vstack
        
        .navigationTitle("The Analysis")
        .navigationBarItems(trailing: Button("", systemImage: favouritesViewModel.isFavorite(symbol: ticker) ? "star.circle.fill" : "star.circle", action: {
                if favouritesViewModel.isFavorite(symbol: ticker) {
                    favouritesViewModel.removeFavorite(symbol: ticker)
                }
                else {
                    favouritesViewModel.addFavorite(stock: FavoriteStock(name: viewModel.stockDetail?.name ?? "", ticker: ticker))
                }
        }).foregroundColor(favouritesViewModel.isFavorite(symbol: ticker) ? .orange : .accentColor)
        )
        .onAppear {
            viewModel.fetchStockDetail(ticker: ticker)
        }
    }//end body
}

struct MetricTile: View{
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .center){
            Image(systemName: icon)
                .padding(.trailing)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
       
    }
}



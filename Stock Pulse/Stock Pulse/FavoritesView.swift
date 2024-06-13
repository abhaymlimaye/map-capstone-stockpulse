//
//  FavoritesView.swift
//  Stock Pulse
//
//  Created by Ruwan Thalgahage on 2024-06-07.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var viewModel = FavoritesViewModel.shared
    
    var body: some View {
            NavigationStack {
                VStack {
                    
                    List {
                        Section("You have \(viewModel.favorites.count) gem(s)") {
                            ForEach(viewModel.favorites) { stock in
                                NavigationLink(destination: StockDetailView(ticker: stock.ticker)) {
                                    HStack {
                                        Text(stock.ticker).font(.headline)
                                        Spacer()
                                        Text(stock.name).font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.trailing)
                                    }
                                }//navlink
                            }
                            .onDelete(perform: deleteFavorite)
                            .onMove(perform: moveFavorite)
                        }//section
                    }//list
                }
                .navigationTitle("The Beloved")
                .navigationBarItems(leading: Text("Your very own Superstars"), trailing: EditButton()) /*trailing: Image(systemName: "star.square.on.square"))*/
            }
        }
    
    private func deleteFavorite(at offsets: IndexSet) {
        for index in offsets {
            viewModel.removeFavorite(symbol: viewModel.favorites[index].ticker)
        }
    }
    
    private func moveFavorite(from source: IndexSet, to destination: Int) {
       viewModel.moveFavorite(from: source, to: destination)
   }
}

#Preview {
    FavoritesView()
}

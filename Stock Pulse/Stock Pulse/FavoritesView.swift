//
//  FavoritesView.swift
//  Stock Pulse
//
//  Created by Ruwan Thalgahage on 2024-06-07.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var viewModel = FavoritesViewModel.shared
    @State private var isShowingShareSheet = false
    
    var body: some View {
            NavigationStack {
                VStack {
                    if viewModel.favorites.count == 0 {
                        Image("AddFavourite-Image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                        Text("Add your Favourites by Taping the Star Button from The Analysis Screen")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        .padding()
                    }
                    else {
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
                } //vstack
                .navigationTitle("The Beloved")
                .toolbar {
                    ToolbarItem(placement: .principal) {Text("")} }
                .navigationBarItems(
                    leading: HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Your Superstars")
                    },
                    trailing: viewModel.favorites.count == 0 ? nil : HStack{
                        EditButton()
                        Button("", systemImage: "paperplane", action: {isShowingShareSheet = true})
                        DarkModeMenu()
                    }
                    .sheet(isPresented: $isShowingShareSheet) { FavouritesShareSheet(items: [viewModel.favoritesAsString]) }
                )//navbaritems
            }//navigation stack
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

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
            }
            .navigationTitle("The Beloved")
            .navigationBarItems(
                leading: Text("Your very own Superstars"),
                trailing: HStack {
                    if viewModel.favorites.count > 0 {
                        Button(action: shareFavorites) {
                            Image(systemName: "square.and.arrow.up.circle")
                        }
                        EditButton()
                    }
                }
            ) /*trailing: Image(systemName: "star.square.on.square"))*/
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
    
    private func shareFavorites() {
        let favoriteTickers = viewModel.favorites.map {$0.ticker}.joined(separator: ", ")
        let activityController = UIActivityViewController(
            //TODO: The share message should be changed
            activityItems:["Stock Pulse - List of Favorites: \(favoriteTickers)"],
            applicationActivities: nil
        )
        
        if let scene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == .foregroundActive
        }) as? UIWindowScene {
            if let rootViewController = scene.windows.first(where: {
                $0.isKeyWindow })?.rootViewController {
                rootViewController.present(activityController, animated: true, completion: nil)
            }
        }
    }
}

#Preview {
    FavoritesView()
}

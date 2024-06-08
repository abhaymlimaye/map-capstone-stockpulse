//
//  SearchView.swift
//  Stock Pulse
//
//  Created by Ruwan Thalgahage on 2024-06-07.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SymbolSearchViewModel()
        @State private var showDetails = false
        @State private var selectedStock: SymbolSearchResult?

        var body: some View {
            NavigationStack {
                VStack {
                    Text("What are you looking for?")
                        .font(.largeTitle)
                        .padding()

                    HStack {
                        TextField("type a symbol or a name...", text: $viewModel.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .submitLabel(.search)
                            .onSubmit {
                                viewModel.search()
                            }

                        Button(action: {
                            viewModel.search()
                        }) {
                            Text("Search")
                        }
                        .padding(.trailing)
                    }
                    
                    List(viewModel.results) { result in
                        NavigationLink(destination: StockDetailView(ticker: result.symbol)) {
                            VStack(alignment: .leading) {
                                Text(result.symbol)
                                    .font(.headline)
                                Text(result.name)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
    }

#Preview {
    SearchView()
}

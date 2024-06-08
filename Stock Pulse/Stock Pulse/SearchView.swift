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
        @State private var showRecordCount = false
        @State private var showLoader = false

        var body: some View {
            NavigationStack {
                VStack {
                    HStack {
                        TextField("type a symbol or a name...", text: $viewModel.searchText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .submitLabel(.search)
                            .onSubmit {
                                showLoader = true
                                viewModel.search()
                            }

//                        Button(action: {
//                            showLoader = true
//                            viewModel.search()
//                        }) {
//                            Text("Search")
//                        }
                        
                    }
                    .padding(.vertical)
              
                    List {
                        Section(showRecordCount ? "Found \(viewModel.results.count) matching" : "") {
                            ForEach(viewModel.results) { result in
                                NavigationLink(destination: StockDetailView(ticker: result.symbol)) {
                                    VStack(alignment: .leading) {
                                        Text(result.symbol)
                                            .font(.headline)
                                        Text(result.name)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .onAppear() {
                                    showLoader = false
                                    showRecordCount = true
                                }
                            }
                        }
                    }
                    .navigationTitle("Let's find")
                }
            }
        }
    }

#Preview {
    SearchView()
}

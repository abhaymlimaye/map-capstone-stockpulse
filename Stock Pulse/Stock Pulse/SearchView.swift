//
//  SearchView.swift
//  Stock Pulse
//
//  Created by Ruwan Thalgahage on 2024-06-07.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SymbolSearchViewModel()
        @State private var selectedStock: SymbolSearchResult?
        @State private var showRecordCount = false

        var body: some View {
            NavigationStack {
                VStack {
                    HStack {
                        TextField("type a symbol or a name...", text: $viewModel.searchText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .submitLabel(.search)
                            .onSubmit {
                                viewModel.search()
                                showRecordCount = true
                            }
                    }
                    .padding(.vertical)
                
                    if !showRecordCount && !viewModel.isLoading {
                        VStack {
                            Image("SearchStock-Image")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                //.frame(width: 250, height: 250)
                            Text("Looking for some specific symbols or companies? We've got you covered! The Search returns the best-matching results based on the keywords of your choice. ")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                  
                    List {
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                        else if let results = viewModel.results {
                            Section(showRecordCount ? "Found \(results.count) matching" : "") {
                                ForEach(results.indices, id: \.self) { index in
                                    let result = results[index]
                                    NavigationLink(destination: StockDetailView(ticker: result.symbol)) {
                                        ResultRow(result: result, isFirstRow: index == 0)
                                    }
                                }
                            }
                        }
                        else if showRecordCount {
                            NoDataPartial()
                        }
                    }
                    .navigationTitle("Let's find a Stock")
                    .navigationBarItems(leading: Text("What do you want to look for?"), trailing: Image(systemName: "waveform.badge.magnifyingglass"))
                }
            }
        }
    }

struct ResultRow: View {
    let result: SymbolSearchResult
    let isFirstRow: Bool
    
    @StateObject private var viewModel = ResultRowViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            if isFirstRow {
                Text("Best Match")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
            }
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    
                    Text(result.symbol)
                        .font(.headline)
                    Text(result.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                if isFirstRow, let iconURL = viewModel.iconURL, let url = URL(string: iconURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40)
                        case .failure:
                            Image(systemName: "wand.and.stars")
                        @unknown default:
                            Image(systemName: "wand.and.stars")
                        }
                    }
                }
            }
        }
        .onAppear {
            if isFirstRow {
                viewModel.fetchIcon(for: result.symbol)
            }
        }
        .onChange(of: result.symbol) {
            if isFirstRow {
                viewModel.fetchIcon(for: result.symbol)
            }
        }
    }
}


#Preview {
    SearchView()
}

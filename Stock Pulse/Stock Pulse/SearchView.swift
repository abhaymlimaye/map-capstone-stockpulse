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
                    }
                    .padding(.vertical)
              
                    List {
                        Section(showRecordCount ? "Found \(viewModel.results.count) matching" : "") {
                            ForEach(viewModel.results.indices, id: \.self) { index in
                                let result = viewModel.results[index]
                                NavigationLink(destination: StockDetailView(ticker: result.symbol)) {
                                    ResultRow(result: result, isFirstRow: index == 0)
                                }
                                .onAppear() {
                                    showLoader = false
                                    showRecordCount = true
                                }
                            }
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
                                .scaledToFit()
                                .frame(height: 30)
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

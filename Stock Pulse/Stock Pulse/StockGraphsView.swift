//
//  StockGraphsView.swift
//  Stock Pulse
//
//  Created by Abhay Limaye on 13-06-2024.
//

import SwiftUI
import Charts

struct StockGraphsView: View {
    var stockDetail: StockDetail
    
    @Binding var show: Bool

    var body: some View {
        ScrollView {
            //header
            HStack(alignment: .center) {
                if let currencyName = stockDetail.currencyName?.uppercased() {
                    Text("Price Trends (\(currencyName))")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).fontWeight(.bold)
                } else {
                    Text("Price Trends")
                }

                Spacer()

                Button("", systemImage: "xmark", action: { show = false }).buttonStyle(BorderlessButtonStyle())
            }
            .padding(.top)
            .padding(.horizontal)
            //end header
            
            ChartSectionView(stockDetail: stockDetail, intervalList: ["1min", "5min", "15min", "30min", "45min", "1h"], title: "Most Recent")
            
            Divider().padding()
            
            ChartSectionView(stockDetail: stockDetail, intervalList: ["1h", "4h", "1day", "1week", "1month"], title: "Historical")
        } //scrollview
    }
}

struct ChartSectionView: View {
    var stockDetail: StockDetail
    var intervalList: [String]
    var title: String
 
    @StateObject private var viewModel = TimeSeriesViewModel()
    
    @State private var selectedInterval = 0
    
    var body: some View {
        VStack() {
            //loading
            if viewModel.isLoading {
                ProgressView().padding()
            }
            //valid data
            else if let timeSeriesValues = viewModel.timeSeriesValues {
                HStack(alignment: .center){
                    Text(title).font(.title2).foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button("", systemImage: "arrow.clockwise", action: { fetchData() })
                    
                    Picker("Interval", selection: $selectedInterval) {
                        ForEach(intervalList.indices, id: \.self) { index in
                            Text(intervalList[index]).tag(index)
                        }
                    }
                    .onChange(of: selectedInterval) { fetchData() } //picker
                }
                .padding(.horizontal)
                
                LineChart(data: timeSeriesValues).frame(height: 320)
            }
            //no data
            else {
                VStack(alignment: .leading) {
                    Text(title).font(.title2).foregroundStyle(.secondary).padding(.vertical)
                    NoDataPartial()
                }
            }
            
        } //vstack
        .onAppear {
            fetchData()
        }
    }
    
    private func fetchData() {
        viewModel.fetchTimeSeries(symbol: stockDetail.ticker ?? "", interval: intervalList[selectedInterval])
    }
}

struct LineChart: View {
    var data: [ConvertedTimeSeriesValue]
    @State private var selectedPriceMetric = 0
    
    private var selectedKeyPath: KeyPath<ConvertedTimeSeriesValue, Double> {
        switch selectedPriceMetric {
            case 0: return \.open
            case 1: return \.close
            case 2: return \.high
            case 3: return \.low
            default: return \.open
        }
    }
    
    private var selectedColor: Color {
        switch selectedPriceMetric {
            case 0: return .purple
            case 1: return .cyan
            case 2: return .green
            case 3: return .red
            default: return .purple
        }
    }
    
    var body: some View {
        VStack {
            Picker("Price Metric", selection: $selectedPriceMetric) {
                Text("Open").tag(0)
                Text("Close").tag(1)
                Text("High").tag(2)
                Text("Low").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom)
            
            Chart(data) { item in
                LineMark(
                    x: .value("Time", item.datetime ),
                    y: .value("Price", item[keyPath: selectedKeyPath] )
                )
                .symbol(.circle)
                .foregroundStyle(Color(selectedColor))
            }
            .chartXAxis {
                AxisMarks(values: data.map { $0.datetime }) { _ in
                    AxisGridLine(centered: false)
                    AxisValueLabel(centered: false, collisionResolution: .greedy, orientation: .verticalReversed)
                }
                
            }
            .chartYAxis{
                AxisMarks(values: data.map{ item in item[keyPath: selectedKeyPath] }) { _ in
                    AxisGridLine(centered: true)
                    AxisValueLabel(centered: false, collisionResolution: .greedy)
                }
            }
            .chartYScale(type: .symmetricLog)
        } //vstack
        .padding()
    }
}

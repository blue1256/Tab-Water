//
//  BarChartView.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/09.
//  Copyright © 2021 박종석. All rights reserved.
//

import Foundation
import Charts
import SwiftUI

struct MonthBarChart: UIViewRepresentable {
    private let waterColor = UIColor.init(red: 125/255, green: 175/255, blue: 235/255, alpha: 1)

    var statsViewModel: StatsViewModel
    var chart = BarChartView()
    var data: [MonthSummary]?
    
    init(viewModel: StatsViewModel) {
        self.statsViewModel = viewModel
        self.data = viewModel.monthSummaries
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(statsViewModel)
    }
    
    func makeUIView(context: Context) -> BarChartView {
        chart.noDataText = "NoRecordsAvailable".localized
        chart.noDataTextColor = waterColor
        chart.maxVisibleCount = 0
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.fitBars = true
        chart.delegate = context.coordinator
        
        let xAxisFormatter = MonthXAxisFormatter(data)
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisMinLabels = 1
        xAxis.granularity = 1
        xAxis.drawGridLinesEnabled = false
        xAxis.valueFormatter = xAxisFormatter
        
        let yAxisFormatter = MonthYAxisFormatter()
        
        let yAxis = chart.rightAxis
        yAxis.axisMinimum = 0
        yAxis.granularity = 0.2
        yAxis.drawAxisLineEnabled = false
        yAxis.axisMaximum = 1
        yAxis.spaceTop = 0.5
        yAxis.valueFormatter = yAxisFormatter
        
        chart.leftAxis.enabled = false
        chart.legend.enabled = false
        chart.chartDescription?.enabled = false
        
        addData()
        
        if chart.data?.yMax ?? 0 > 1 {
            yAxis.resetCustomAxisMax()
        }
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {}
    
    func addData() {
        guard let data = data else { return }
        
        let values = data.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: $0.element.totalDrank) }
        let dataSet = BarChartDataSet(entries: values)
        dataSet.axisDependency = .right
        dataSet.setColor(waterColor)
        dataSet.highlightAlpha = 0
        
        let barData = BarChartData(dataSet: dataSet)
        barData.barWidth = 0.5
        
        chart.data = barData
        chart.notifyDataSetChanged()
        chart.zoom(scaleX: CGFloat(Double(values.count)/4.0), scaleY: 1, x: 0, y: 0)
        chart.moveViewToX(Double(values.count))
        chart.animate(yAxisDuration: 1)
    }
    
    class Coordinator: NSObject, ChartViewDelegate {
        @ObservedObject var statsViewModel: StatsViewModel
        
        init(_ viewModel: StatsViewModel) {
            self.statsViewModel = viewModel
        }
        
        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            statsViewModel.showingMonthIndex = Int(entry.x)
        }
    }
}

class MonthXAxisFormatter: IAxisValueFormatter {
    var data: [MonthSummary]?
    
    init(_ data: [MonthSummary]?) {
        self.data = data
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let data = data else {
            return "-"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMM"
        let month = dateFormatter.date(from: data[Int(value)].month)
        
        dateFormatter.dateFormat = "StatsMonthFormat".localized
        return dateFormatter.string(from: month ?? Date())
    }
}

class MonthYAxisFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(format: "%.1lfL", value)
    }
}

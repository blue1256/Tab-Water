//
//  DayLineChart.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/11.
//  Copyright © 2021 박종석. All rights reserved.
//

import Foundation
import Charts
import SwiftUI

struct DayLineChart: UIViewRepresentable {
    private let waterColor = UIColor.init(red: 125/255, green: 175/255, blue: 235/255, alpha: 1)
    private let transparentWaterColor = UIColor.init(red: 125/255, green: 175/255, blue: 235/255, alpha: 0.6)

    var viewModel: RecordDetailViewModel
    var chart = LineChartView()
    var data: [DrinkLogItem]
    var lastTime: Int
    
    init(viewModel: RecordDetailViewModel) {
        self.viewModel = viewModel
        self.data = Array(viewModel.record.drinkLog)
        self.lastTime = viewModel.lastTime
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(chart, viewModel)
    }
    
    func makeUIView(context: Context) -> LineChartView {
        chart.noDataText = "NoRecordsAvailable".localized
        chart.noDataTextColor = waterColor
        chart.maxVisibleCount = 0
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.delegate = context.coordinator
        
        let xAxisFormatter = DayXAxisFormatter(size: lastTime)
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisMinLabels = 1
        xAxis.granularity = 1
        xAxis.drawGridLinesEnabled = false
        xAxis.yOffset = 10
        xAxis.valueFormatter = xAxisFormatter
        
        let yAxisFormatter = DayYAxisFormatter()
        
        let goal = self.viewModel.record.dailyGoal
        
        let yAxis = chart.rightAxis
        yAxis.axisMinimum = 0
        yAxis.granularity = 0.2
        yAxis.drawAxisLineEnabled = false
        yAxis.axisMaximum = goal * 1.25
        yAxis.spaceTop = 0.5
        yAxis.xOffset = 10
        yAxis.valueFormatter = yAxisFormatter
        
        let limit = ChartLimitLine(limit: goal, label: "Goal".localized)
        limit.lineColor = waterColor
        yAxis.addLimitLine(limit)
        
        chart.leftAxis.enabled = false
        chart.legend.enabled = false
        chart.chartDescription?.enabled = false
        
        addData()
        
        if chart.data?.yMax ?? 0 > goal {
            yAxis.resetCustomAxisMax()
        }
        return chart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {}
    
    func addData() {
        var values = [ChartDataEntry]()
        (0...lastTime).forEach { index in
            values.append(ChartDataEntry(x: Double(index), y: 0.0))
        }
        data.forEach { item in
            let endIndex = item.time.index(item.time.startIndex, offsetBy: 1)
            let time = Int(item.time[...endIndex]) ?? Int.max
            if time < values.count {
                values[time+1].y += item.volume
            }
        }
        
        (0...lastTime).forEach { index in
            if index == 0 {
                return
            }
            values[index].y += values[index-1].y
        }
        
        let dataSet = LineChartDataSet(entries: values)
        dataSet.axisDependency = .right
        dataSet.setColor(waterColor)
        dataSet.drawFilledEnabled = true
        dataSet.fillColor = transparentWaterColor
        dataSet.circleRadius = 6
        dataSet.circleHoleRadius = 2
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.highlightColor = transparentWaterColor
        dataSet.highlightLineWidth = 1
        
        let lineData = LineChartData(dataSet: dataSet)
        
        chart.data = lineData
        chart.notifyDataSetChanged()
        chart.zoom(scaleX: CGFloat(Double(values.count)/6.0), scaleY: 1, x: 0, y: 0)
        chart.moveViewToX(Double(values.count))
        chart.animate(yAxisDuration: 0.5)
        chart.highlightValue(x: Double(lastTime), dataSetIndex: 0)
    }
    
    class Coordinator: NSObject, ChartViewDelegate {
        @ObservedObject var viewModel: RecordDetailViewModel
        var chart: LineChartView
        
        init(_ chart: LineChartView, _ viewModel: RecordDetailViewModel) {
            self.viewModel = viewModel
            self.chart = chart
        }
        
        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            viewModel.selectedTime = Int(entry.x)
            viewModel.selectedVolume = entry.y
        }
        
        func chartValueNothingSelected(_ chartView: ChartViewBase) {
            chart.highlightValue(x: Double(viewModel.selectedTime), dataSetIndex: 0)
        }
    }
}

class DayXAxisFormatter: IAxisValueFormatter {
    var size: Int
    init(size: Int) {
        self.size = size
    }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if Int(value) == size {
            return "Now".localized
        }
        return String(format: "ChartTimeFormat".localized, Int(value))
    }
}

class DayYAxisFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(format: "%.1lfL", value)
    }
}

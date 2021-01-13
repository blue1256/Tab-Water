//
//  RecordDetailView.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/11.
//  Copyright © 2021 박종석. All rights reserved.
//

import SwiftUI

extension RecordDetailView {
    func chartView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .center) {
            Text(self.viewModel.date)
                .font(.largeTitle)
            DayLineChart(viewModel: self.viewModel)
                .frame(width: geometry.size.width - 32, height: 300)
            
            HStack {
                Text(viewModel.selectedTimeFormatted)
                    .font(.system(size: 20, weight: .bold))
                    .frame(width: geometry.size.width/2-16)
                Divider()
                Text(String(format: "%.2lfL", viewModel.selectedVolume))
                    .frame(width: geometry.size.width/2-16)
            }
            Divider()
                .padding(.bottom, 16)
            
            HStack {
                Text("Drank".localized)
                    .frame(width: 150, alignment: .leading)
                    .font(.headline)
                Spacer()
                Text("Goal".localized)
                    .frame(width: 150, alignment: .leading)
                    .font(.headline)
                Spacer()
            }
            .padding([.leading, .trailing], 32)
            HStack(alignment: .top) {
                Text(String(format: "%.2lfL", viewModel.record.drankToday))
                    .frame(width: 150, alignment: .leading)
                Spacer()
                Text(String(format: "%.2lfL", viewModel.record.dailyGoal))
                    .frame(width: 150, alignment: .leading)
                Spacer()
            }
            .padding([.leading, .trailing], 32)
            .padding(.bottom, 16)
            
            HStack(alignment: .top) {
                Text("AveragePerHour".localized)
                    .frame(width: 150, alignment: .leading)
                    .font(.headline)
                Spacer()
                Text("PeakTime".localized)
                    .frame(width: 150, alignment: .leading)
                    .font(.headline)
                Spacer()
            }
            .padding([.leading, .trailing], 32)
            HStack {
                Text(String(format: "%.2lfL", viewModel.record.drankToday/Double(viewModel.lastTime)))
                    .frame(width: 150, alignment: .leading)
                Spacer()
                Text(viewModel.peakTime)
                    .frame(width: 150, alignment: .leading)
                Spacer()
            }
            .padding([.leading, .trailing], 32)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }
    
    var listView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Time".localized)
                    .bold()
                    .frame(width: 120, alignment: .leading)
                    .padding(.leading, 16)
                Rectangle().fill(Color.clear).frame(width:1, height: 50)
                Text("Drank".localized)
                    .padding(.leading, 32)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            ForEach(viewModel.record.drinkLog) { LogListViewItem(logItem: $0) }
        }
    }
}

struct RecordDetailView: View {
    var showDelete: Bool = false
    @ObservedObject var viewModel: RecordDetailViewModel
    var recordViewModel: RecordViewModel?
    
    init(recordViewModel: RecordViewModel? = nil, record: DayRecord, isToday: Bool = false) {
        self.recordViewModel = recordViewModel
        viewModel = RecordDetailViewModel(record: record)
        self.showDelete = isToday
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack {
                    Text("Detail".localized)
                        .font(.system(size: 30, weight: .semibold))
                        .padding(.leading, 16)
                    
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(dampingFraction: 0.75)) {
                            viewModel.showChart.toggle()
                        }
                    }, label: {
                        if viewModel.showChart {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 17, weight: .bold))
                        } else {
                            Image(systemName: "chart.bar.fill")
                        }
                    })
                    .padding(.trailing, 16)
                    .foregroundColor(.gray)

                }
                .padding(.top, 16)
                
                ScrollView {
                    if viewModel.showChart {
                        chartView(geometry: geometry)
                            .transition(AnyTransition.scale.combined(with: .opacity))
                    } else {
                        listView
                            .transition(AnyTransition.scale.combined(with: .opacity))
                    }
                }
                if showDelete {
                    HStack {
                        Button(action: {
                            viewModel.showRecordDeletionSheet.toggle()
                        }){
                            HStack {
                                Image(systemName: "trash")
                                Text("RemoveRecord".localized)
                            }
                            .foregroundColor(.red)
                        }
                        .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .actionSheet(isPresented: $viewModel.showRecordDeletionSheet) {
                let delete = ActionSheet.Button.destructive(Text("RemoveRecord".localized)) {
                    viewModel.removeLastRecord()
                    recordViewModel?.initializeRecord()
                }
                let cancel = ActionSheet.Button.cancel(Text("Cancel".localized))
                let sheet = ActionSheet(title: Text(""), message: Text("RemoveRecordContent".localized), buttons: [delete, cancel])
                return sheet
            }
        }
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailView(recordViewModel: RecordViewModel(), record: DayRecord(drankToday: 0, dailyGoal: 2, date: "20201212"))
    }
}

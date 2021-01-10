//
//  StatsView.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/09.
//  Copyright © 2021 박종석. All rights reserved.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var statsViewModel = StatsViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text("Stats".localized)
                    .font(.system(size: 30, weight: .semibold))
                    .padding([.top, .leading])
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("TotalRecords".localized)
                            .font(.system(size: 22))
                            .padding([.leading, .trailing, .bottom])
                        HStack() {
                            Text("TotalDrank".localized)
                                .frame(width: 150, alignment: .leading)
                                .font(.headline)
                            Spacer()
                            Text("GoalMet".localized)
                                .frame(width: 150, alignment: .leading)
                                .font(.headline)
                            Spacer()
                        }
                        .padding([.leading, .trailing], 32)
                        HStack(alignment: .top) {
                            Text(String(format: "%.2lfL", self.statsViewModel.totalDrank))
                                .frame(width: 150, alignment: .leading)
                            Spacer()
                            Text("DayFormat".localized(self.statsViewModel.goalMet))
                                .frame(width: 150, alignment: .leading)
                            Spacer()
                        }
                        .padding([.leading, .trailing], 32)
                        .padding(.bottom, 16)
                        HStack(alignment: .top) {
                            Text("HighestRecord".localized)
                                .frame(width: 150, alignment: .leading)
                                .font(.headline)
                            Spacer()
                            Text("HighestRecordDate".localized)
                                .frame(width: 150, alignment: .leading)
                                .font(.headline)
                            Spacer()
                        }
                        .padding([.leading, .trailing], 32)
                        HStack {
                            Text(String(format: "%.2lfL", self.statsViewModel.highestRecord))
                                .frame(width: 150, alignment: .leading)
                            Spacer()
                            Text(self.statsViewModel.highestRecordDate)
                                .frame(width: 150, alignment: .leading)
                            Spacer()
                        }
                        .padding([.leading, .trailing], 32)
                        
                        Text("SummaryChart".localized)
                            .font(.system(size: 22))
                            .padding()
                        
                        HStack {
                            Spacer()
                            MonthBarChart(viewModel: self.statsViewModel)
                                .frame(width: geometry.size.width - 32, height: 300, alignment: .center)
                            Spacer()
                        }
                        .padding(.bottom, 16)
                        
                        Text("MonthSummary".localized)
                            .font(.system(size: 22))
                            .padding()
                        
                        if let monthSummaries = self.statsViewModel.monthSummaries {
                            PageView(currentPage: self.$statsViewModel.showingMonthIndex, monthSummaries.map{ MonthSummaryView(monthSummary: $0) }
                            )
                            .frame(height: 640)
                        } else {
                            Text("NoRecordsAvailable".localized)
                                .padding()
                        }
                    }
                }
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}

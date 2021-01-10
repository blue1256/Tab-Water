//
//  MonthSummaryView.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/10.
//  Copyright © 2021 박종석. All rights reserved.
//

import SwiftUI

struct MonthSummaryView: View {
    var monthSummary: MonthSummary
    var percentage: Double = 0
    var highestRecordDate: String = "-"
    var monthTitle: String = ""
    
    init(monthSummary: MonthSummary) {
        let formatter = DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        
        self.monthSummary = monthSummary
        self.percentage = monthSummary.totalGoal == 0 ? 0 : monthSummary.totalDrank / monthSummary.totalGoal
        if let mostDate = monthSummary.mostDrankDate {
            formatter.dateFormat = "yyyyMMdd"
            let date = formatter.date(from: mostDate)
            if let d = date {
                formatter.dateFormat = "MonthSummaryDateFormat".localized
                self.highestRecordDate = formatter.string(from: d)
            }
        }
        formatter.dateFormat = "yyyyMM"
        let month = formatter.date(from: monthSummary.month)
        formatter.dateFormat = "StatsMonthFormat".localized
        monthTitle = formatter.string(from: month ?? Date())
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Text(monthTitle)
                    .font(.largeTitle)
                
                CirclePercentageView(percentage: percentage)
                    .frame(width: geometry.size.width - 72, height: geometry.size.width - 72)
                    .padding(.bottom, 16)
                
                HStack() {
                    Text("TotalDrank".localized)
                        .frame(width: 150, alignment: .leading)
                        .font(.headline)
                    Spacer()
                    Text("TotalGoal".localized)
                        .frame(width: 150, alignment: .leading)
                        .font(.headline)
                    Spacer()
                }
                .padding([.leading, .trailing], 32)
                HStack(alignment: .top) {
                    Text(String(format: "%.2lfL", monthSummary.totalDrank))
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    Text(String(format: "%.2lfL", monthSummary.totalGoal))
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
                    Text(String(format: "%.2lfL", monthSummary.mostDrank))
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                    Text(highestRecordDate)
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                }
                .padding([.leading, .trailing], 32)
                .padding(.bottom, 16)
                
                HStack(alignment: .top) {
                    Text("GoalMet".localized)
                        .frame(width: 150, alignment: .leading)
                        .font(.headline)
                    Spacer()
                }
                .padding([.leading, .trailing], 32)
                HStack {
                    Text("DayFormat".localized(monthSummary.achievedDays))
                        .frame(width: 150, alignment: .leading)
                    Spacer()
                }
                .padding([.leading, .trailing], 32)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct MonthSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        MonthSummaryView(monthSummary: MonthSummary("202011"))
    }
}

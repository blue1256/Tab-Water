//
//  StatsViewModel.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/09.
//  Copyright © 2021 박종석. All rights reserved.
//

import Foundation
import Combine
import Charts

class StatsViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let dateFormatter = DateFormatter()
    
    @Published var records: [DayRecord]
    @Published var monthSummaries: [MonthSummary]? = nil
    @Published var totalDrank: Double = 0
    @Published var goalMet: Int = 0
    @Published var highestRecord: Double = 0
    @Published var highestRecordDate: String = "-"
    @Published var showingMonthIndex: Int = 0
    
    init() {
        records = StoreManager.shared.getAllRecords()
        dateFormatter.timeZone = .autoupdatingCurrent
        
        self.$records
            .sink { [weak self] recs in
                guard let self = self else { return }
                var summaries = [MonthSummary]()
                self.totalDrank = 0
                self.goalMet = 0
                self.highestRecord = 0
                self.highestRecordDate = ""
                var firstMonth = Int.max
                var lastMonth = 0
                recs.forEach{ record in
                    let endIndex = record.date.index(record.date.startIndex, offsetBy: 5)
                    
                    if let summary = summaries.first(where: { $0.month == record.date[...endIndex] }) {
                        summary.totalGoal += record.dailyGoal
                        summary.totalDrank += record.drankToday
                        summary.achievedDays += (record.drankToday >= record.dailyGoal ? 1 : 0)
                        if record.drankToday > summary.mostDrank {
                            summary.mostDrank = record.drankToday
                            summary.mostDrankDate = record.date
                        }
                    } else {
                        summaries.append(MonthSummary(firstRecord: record))
                    }
                    
                    if let recordMonth = Int(record.date[...endIndex]), firstMonth > recordMonth {
                        firstMonth = recordMonth
                    }
                    if let recordMonth = Int(record.date[...endIndex]), lastMonth < recordMonth {
                        lastMonth = recordMonth
                    }
                    
                    self.totalDrank += record.drankToday
                    self.goalMet += (record.drankToday >= record.dailyGoal) ? 1 : 0
                    if self.highestRecord < record.drankToday {
                        self.highestRecord = record.drankToday

                        self.dateFormatter.dateFormat = "yyyyMMdd"
                        let date = self.dateFormatter.date(from: record.date)
                        
                        self.dateFormatter.dateFormat = "StatsDateFormat".localized
                        self.highestRecordDate = self.dateFormatter.string(from: date ?? Date())
                    }
                }
                if firstMonth < lastMonth {
                    let monthRange = firstMonth...lastMonth
                    
                    monthRange.forEach { month in
                        if (month % 100) < 1 || (month % 100) > 12 {
                            return
                        }
                        if summaries.contains(where: { Int($0.month) == month }) {
                            return
                        }
                        summaries.append(MonthSummary("\(month)"))
                    }
                }
                self.monthSummaries = summaries.sorted(by: { $0.month < $1.month })
                self.showingMonthIndex = summaries.count-1
            }
            .store(in: &cancellables)
    }
}

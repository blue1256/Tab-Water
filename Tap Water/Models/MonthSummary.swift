//
//  MonthSummary.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/09.
//  Copyright © 2021 박종석. All rights reserved.
//

import Foundation

final class MonthSummary {
    var month: String
    var totalGoal: Double = 0
    var totalDrank: Double = 0
    var achievedDays: Int = 0
    var mostDrankDate: String? = nil
    var mostDrank: Double = 0
    
    init(_ month: String) {
        self.month = month
    }
    
    convenience init(firstRecord: DayRecord) {
        let endIndex = firstRecord.date.index(firstRecord.date.startIndex, offsetBy: 5)
        self.init(String(firstRecord.date[...endIndex]))
        
        self.totalGoal = firstRecord.dailyGoal
        self.totalDrank = firstRecord.drankToday
        self.achievedDays = firstRecord.drankToday >= firstRecord.dailyGoal ? 1 : 0
        if firstRecord.drankToday != 0 {
            self.mostDrankDate = firstRecord.date
            self.mostDrank = firstRecord.drankToday
        }
    }
}

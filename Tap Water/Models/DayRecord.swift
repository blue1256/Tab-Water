//
//  DayRecord.swift
//  Tap Water
//
//  Created by 박종석 on 2020/04/04.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation

class DayRecord: Codable {
    var drankToday: Double = 0.0
    var dailyGoal: Double = 0.0
    var date: String = ""
    
    init() {}
    
    init(drankToday: Double, dailyGoal: Double, date: String) {
        self.drankToday = drankToday
        self.dailyGoal = dailyGoal
        self.date = date
    }
}

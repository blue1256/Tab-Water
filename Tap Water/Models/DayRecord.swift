//
//  DayRecord.swift
//  Tap Water
//
//  Created by 박종석 on 2020/04/04.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import RealmSwift

class DayRecord: Object, NSCopying, Codable {
    @objc dynamic var drankToday: Double = 0.0
    @objc dynamic var dailyGoal: Double = 0.0
    @objc dynamic var date: String = ""
    
    convenience init(drankToday: Double, dailyGoal: Double, date: String) {
        self.init()
        self.drankToday = drankToday
        self.dailyGoal = dailyGoal
        self.date = date
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return DayRecord(drankToday: self.drankToday, dailyGoal: self.dailyGoal, date: self.date)
    }
}

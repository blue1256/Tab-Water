//
//  RecordDetailViewModel.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/11.
//  Copyright © 2021 박종석. All rights reserved.
//

import Foundation
import Combine

class RecordDetailViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let formatter = DateFormatter()
    
    @Published var record: DayRecord
    @Published var rerenderChart: Bool = false
    @Published var isToday: Bool
    @Published var showChart: Bool = true
    
    @Published var date: String = "-"
    
    @Published var selectedTime: Int = 0
    @Published var selectedVolume: Double = 0.0
    @Published var selectedTimeFormatted: String = "Now".localized
    @Published var peakTime: String = "-"
    @Published var lastTime: Int = 1
    
    @Published var showRecordDeletionSheet: Bool = false
    
    func removeLastRecord() {
        record.drankToday -= record.drinkLog.last?.volume ?? 0
        record.drinkLog.removeLast()
        
        StoreManager.shared.setTodayRecord(record)
        
        record = StoreManager.shared.getRecord(date: record.date)
        rerenderChart = true
    }
    
    init(record: DayRecord) {
        self.record = record
        formatter.timeZone = .autoupdatingCurrent
        
        formatter.dateFormat = "yyyyMMdd"
        self.isToday = (record.date == formatter.string(from: Date()))
        
        formatter.dateFormat = "HH"
        
        lastTime = self.isToday ? (Int(formatter.string(from: Date())) ?? 0)+1 : 24
        selectedTime = lastTime
        
        self.$record
            .sink { [weak self] record in
                guard let self = self else { return }
                self.formatter.dateFormat = "yyyyMMdd"
                let d = self.formatter.date(from: record.date)
                
                self.formatter.dateFormat = "StatsDateFormat".localized
                self.date = self.formatter.string(from: d ?? Date())
                
                var mostDrank = 0.0
                var mostDrankTime = -1
                var drankSoFar = 0.0
                var timeSoFar = 0
                record.drinkLog.forEach { item in
                    let endIndex = item.time.index(item.time.startIndex, offsetBy: 1)
                    let t = item.time[...endIndex]
                    guard let time = Int(t) else { return }
                    if timeSoFar < time {
                        if drankSoFar > mostDrank {
                            mostDrank = drankSoFar
                            mostDrankTime = timeSoFar
                        }
                        timeSoFar = time
                        drankSoFar = 0
                    }
                    drankSoFar += item.volume
                }
                if drankSoFar > mostDrank {
                    mostDrank = drankSoFar
                    mostDrankTime = timeSoFar
                }
                if mostDrankTime > -1 {
                    self.peakTime = "\(Utils.shared.convertTimeFormat(time: mostDrankTime)) - \(Utils.shared.convertTimeFormat(time: mostDrankTime+1))"
                } else {
                    self.peakTime = "-"
                }
            }
            .store(in: &cancellables)
        
        self.$selectedTime
            .removeDuplicates()
            .sink { [weak self] time in
                guard let self = self else { return }
                if time < self.lastTime || !self.isToday {
                    self.selectedTimeFormatted = Utils.shared.convertTimeFormat(time: time)
                } else {
                    self.selectedTimeFormatted = "Now".localized
                }
            }
            .store(in: &cancellables)
    }
}

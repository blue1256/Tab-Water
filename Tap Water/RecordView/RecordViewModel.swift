//
//  RecordViewModel.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/27.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import Combine

class RecordViewModel: ObservableObject {
    private let timerPublisher = Timer.TimerPublisher(interval: 0.1, runLoop: .main, mode: .default)
    private var cancellables = Set<AnyCancellable>()
    
    private let formatter = DateFormatter()
    
    @Published var todayRecord: DayRecord? = nil
    
    @Published var drankToday: Double = 0.0
    @Published var drankNow: Double = 0.0
    @Published var dailyGoal: Double = 0.0
    @Published var speed: Double = 0.0
   
    @Published var percentage: Double = 0.0
    @Published var showAlert: Bool = false
    @Published var isDrinking: Bool = false
    @Published var showCompleted: Bool = false
    @Published var showDetail: Bool = false
    @Published var showSheet: Bool = false
    
    @Published var examineSetting: Bool = false
    
    @Published var showUserSetting: Bool = false
    
    @Published var launchedBefore: Bool = true
    
    init(){
        timerPublisher.connect().store(in: &cancellables)
        
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyyMMdd"
        
        dailyGoal = UserDefaults.standard.double(forKey: "dailyGoal")
        speed = UserDefaults.standard.double(forKey: "speed")
        
        showAlert = (dailyGoal == 0) || (speed == 0)
        launchedBefore = AppState.shared.launchedBefore
        
        var comps = DateComponents()
        comps.hour = 0
        
        let date = Calendar.current.nextDate(after: Date(), matching: comps, matchingPolicy: .nextTime, direction: .forward)
        let timer = Timer(fireAt: date!, interval: 86400, target: self, selector: #selector(getNewRecord), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        
        initializeRecord()
        
        self.$todayRecord
            .sink { [weak self] record in
                guard let self = self else { return }
                let drankToday = record?.drankToday ?? 0
                self.drankToday = drankToday
                self.percentage = drankToday / self.dailyGoal
            }
            .store(in: &cancellables)
        
        self.$dailyGoal
            .removeDuplicates()
            .sink { [weak self] goal in
                guard let self = self else { return }
                self.dailyGoal = goal
                if self.dailyGoal != 0 {
                    self.percentage = self.drankToday / self.dailyGoal
                }
            }
            .store(in: &cancellables)
        
        self.$isDrinking
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self, let record = self.todayRecord else { return }
                if !self.launchedBefore {
                    self.launchedBefore.toggle()
                    AppState.shared.launchedBefore.toggle()
                }
                
                StoreManager.shared.setTodayRecord(record)
            }
            .store(in: &cancellables)
        
        self.$isDrinking
            .dropFirst()
            .filter { !$0 }
            .sink { [weak self] _ in
                guard let self = self, let record = self.todayRecord else { return }
                record.drankToday += self.drankNow
                
                self.formatter.dateFormat = "hh:mm:ss"
                record.drinkLog.append(DrinkLogItem(time: self.formatter.string(from: Date()), volume: self.drankNow))
                
                self.drankNow = 0
                StoreManager.shared.setTodayRecord(record)
                AppState.shared.updateCalendar = true
            }
            .store(in: &cancellables)
        
        self.$isDrinking
            .combineLatest(timerPublisher)
            .map { return $0.0 }
            .filter{ $0 }
            .sink { [weak self] drinking in
                guard let self = self else { return }
                self.drankNow += 0.1 * self.speed / 1000
                self.drankToday += 0.1 * self.speed / 1000
                let drankToday = self.drankToday
                let dailyGoal = self.dailyGoal
                if dailyGoal != 0 {
                    self.percentage = drankToday / dailyGoal
                }
            }
            .store(in: &cancellables)
        
        self.$percentage
            .combineLatest(self.$isDrinking)
            .filter { $0 >= 1 && !$1 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                if !AppState.shared.completedToday {
                    self.showCompleted = true
                    AppState.shared.completedToday = true
                }
            }
            .store(in: &cancellables)
        
        self.$showUserSetting
            .filter { $0 }
            .sink { _ in
                AppState.shared.selectedTab = 2
                AppState.shared.showUserSetting = true
            }
            .store(in: &cancellables)
        
        self.$examineSetting
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.showAlert = (self.dailyGoal == 0) || (self.speed == 0)
            }
            .store(in: &cancellables)
        
        self.$showDetail
            .filter { !$0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.initializeRecord()
            }
            .store(in: &cancellables)
        
        self.$showDetail
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.showSheet = true
            }
            .store(in: &cancellables)
        
        self.$showCompleted
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.showSheet = true
            }
            .store(in: &cancellables)
        
        self.$showSheet
            .filter { !$0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.showCompleted = false
                self.showDetail = false
            }
            .store(in: &cancellables)
    }
    
    func initializeRecord() {
        todayRecord = StoreManager.shared.getTodayRecord()
        formatter.dateFormat = "yyyyMMdd"
        let today = formatter.string(from: Date())
        
        if let record = todayRecord, today == record.date {
            drankToday = record.drankToday
            dailyGoal = record.dailyGoal
        } else {
            getNewRecord()
        }
    }
    
    @objc func getNewRecord(){
        let today = AppState.shared.today
        let userDefault = UserDefaults.standard
        
        userDefault.set(0.0, forKey: "drankToday")
        userDefault.set(false, forKey: "completedToday")
        AppState.shared.completedToday = false
        
        drankToday = 0.0
        let record = DayRecord(drankToday: drankToday, dailyGoal: dailyGoal, date: today)
        self.todayRecord = record
        
        StoreManager.shared.setTodayRecord(record)
        
        userDefault.set(today, forKey: "today")
    }
}

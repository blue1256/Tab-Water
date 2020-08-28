//
//  UserProfile.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/26.
//  Copyright © 2020 박종석. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import Combine

final class UserProfile: ObservableObject {
    static let shared = UserProfile()
    let userDefault = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    @Published var todayRecord: DayRecord? = nil
    
    @Published var completedToday: Bool = false
    @Published var updateRecord: Bool = false
    @Published var dailyGoal: Double
    @Published var speed: Double
    @Published var enabledNotification: Bool = true
    @Published var remindingTime: Int = 1
    
    @objc func dateChange(){
        self.getNewRecord(today: AppState.shared.today)
    }
    
    func getNewRecord(today: String) {
        if let defaultDate = userDefault.string(forKey: "today"), defaultDate != today {
            userDefault.set(0, forKey: "drankToday")
            userDefault.set(false, forKey: "completedToday")
            completedToday = false
        }
        
        let drankToday = userDefault.double(forKey: "drankToday")
        todayRecord = DayRecord(drankToday: drankToday, dailyGoal: dailyGoal, date: today)
        
        userDefault.set(today, forKey: "today")
    }
    
    private init() {
        speed = userDefault.double(forKey: "speed")
        dailyGoal = userDefault.double(forKey: "dailyGoal")
        completedToday = userDefault.bool(forKey: "completedToday")
        enabledNotification = !userDefault.bool(forKey: "notification")
        remindingTime = userDefault.integer(forKey: "remindingTime") == 0 ? 1 : userDefault.integer(forKey: "remindingTime")
        
        let today = AppState.shared.today
        
        getNewRecord(today: today)
        
        var comps = DateComponents()
        comps.hour = 0
        
        let date = Calendar.current.nextDate(after: Date(), matching: comps, matchingPolicy: .nextTime, direction: .forward)
        
        let timer = Timer(fireAt: date!, interval: 86400, target: self, selector: #selector(dateChange), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        
        self.$dailyGoal
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] goal in
                self?.userDefault.set(goal, forKey: "dailyGoal")
            }
            .store(in: &cancellables)
        
        self.$speed
            .sink { [weak self] speed in
                self?.userDefault.set(speed, forKey: "speed")
            }
            .store(in: &cancellables)
        
        self.$updateRecord
            .filter{ $0 }
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                if let record = self?.todayRecord {
                    StoreManager.shared.setTodayRecord(record)
                    self?.userDefault.set(record.drankToday, forKey: "drankToday")
                }
                self?.updateRecord = false
            }
            .store(in: &cancellables)
        
        self.$completedToday
            .sink{ [weak self] comp in
                self?.userDefault.set(comp, forKey: "completedToday")
            }
            .store(in: &cancellables)
        
        self.$enabledNotification
            .sink{ [weak self] enabled in
                guard let self = self else { return }
                self.userDefault.set(!enabled, forKey: "notification")
            }
            .store(in: &cancellables)
        
        self.$remindingTime
            .sink { [weak self] time in
                guard let self = self else { return }
                self.userDefault.set(time, forKey: "remindingTime")
            }
            .store(in: &cancellables)
    }
}

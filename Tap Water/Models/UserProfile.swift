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
    
    func getNewRecord(today: String) {
        let drankToday = userDefault.double(forKey: "drankToday")
        
        if let defaultDate = userDefault.string(forKey: "today") {
            if defaultDate == today {
                todayRecord = DayRecord(drankToday: drankToday, dailyGoal: dailyGoal, date: today)
            } else {
                userDefault.set(0, forKey: "drankToday")
                userDefault.set(false, forKey: "completedToday")
                completedToday = false
            }
        }
        
        userDefault.set(today, forKey: "today")
    }
    
    private init() {
        speed = userDefault.double(forKey: "speed")
        dailyGoal = userDefault.double(forKey: "dailyGoal")
        completedToday = userDefault.bool(forKey: "completedToday")
        
        let today = AppState.shared.today
        
        getNewRecord(today: today)
        
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
    }
}

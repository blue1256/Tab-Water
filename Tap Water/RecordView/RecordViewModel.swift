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
    var userProfile: UserProfile = UserProfile.shared
    let appState = AppState.shared
    private let timerPublisher = Timer.TimerPublisher(interval: 0.3, runLoop: .main, mode: .default)
    private var cancellables = Set<AnyCancellable>()
    
    var drankToday: Double = 0.0
    var dailyGoal: Double = 0.0
   
    @Published var percentage: Double = 0.0
    @Published var showAlert: Bool = false
    @Published var isDrinking: Bool = false
    @Published var completed: Bool = false
    @Published var showCompleted: Bool = false
    
    @Published var examineSetting: Bool = false
    
    @Published var showUserSetting: Bool = false
    
    @Published var today: String = ""
    
    init(){
        timerPublisher.connect().store(in: &cancellables)
        drankToday = userProfile.todayRecord?.drankToday ?? 0
        dailyGoal = userProfile.dailyGoal
        showAlert = (userProfile.dailyGoal == 0) || (userProfile.speed == 0)
        
        userProfile.$todayRecord
            .sink { [weak self] record in
                let drankToday = record?.drankToday ?? 0
                self?.drankToday = drankToday
                if let dailyGoal = self?.dailyGoal {
                    self?.percentage = drankToday / dailyGoal
                }
            }
            .store(in: &cancellables)
        
        userProfile.$dailyGoal
            .removeDuplicates()
            .sink { [weak self] goal in
                self?.dailyGoal = goal
                if let drankToday = self?.drankToday, goal != 0 {
                    self?.percentage = drankToday / goal
                }
            }
            .store(in: &cancellables)
        
        self.$isDrinking
            .combineLatest(timerPublisher)
            .map { return $0.0 }
            .filter{ $0 }
            .sink { [weak self] _ in
                self?.drankToday += 0.3 * (self?.userProfile.speed ?? 0) / 1000
                if let drankToday = self?.drankToday, let dailyGoal = self?.userProfile.dailyGoal, dailyGoal != 0 {
                    self?.percentage = drankToday / dailyGoal
                    self?.userProfile.todayRecord?.drankToday = drankToday
                }
                self?.userProfile.updateRecord = true
            }
            .store(in: &cancellables)
        
        self.$percentage
            .filter { $0 >= 1 }
            .first()
            .sink { [weak self] _ in
                self?.completed = true
                self?.userProfile.completedToday = true
            }
            .store(in: &cancellables)
        
        self.$completed
            .combineLatest(self.$isDrinking)
            .filter { $0 && !$1 }
            .first()
            .sink { [weak self] _ in
                if let alreadyComp = self?.userProfile.completedToday, alreadyComp == false {
                    self?.showCompleted = true
                }
            }
            .store(in: &cancellables)
        
        self.$showUserSetting
            .filter { $0 }
            .sink { [weak self] _ in
                self?.appState.selectedTab = 2
                self?.appState.showUserSetting = true
            }
            .store(in: &cancellables)
        
        self.$examineSetting
            .filter { $0 }
            .sink { [weak self] _ in
                self?.showAlert = (self?.userProfile.dailyGoal == 0) || (self?.userProfile.speed == 0)
            }
            .store(in: &cancellables)
        
        self.$today
            .dropFirst()
            .filter{ today in
                guard let defaultToday = UserDefaults.standard.string(forKey: "today") else {
                    return false
                }
                return defaultToday != today
            }
            .sink { [weak self] today in
                self?.userProfile.getNewRecord(today: today)
            }
            .store(in: &cancellables)
    }
}

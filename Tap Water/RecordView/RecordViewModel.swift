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
    private let timerPublisher = Timer.TimerPublisher(interval: 0.2, runLoop: .main, mode: .default)
    private var cancellables = Set<AnyCancellable>()
    
    @Published var drankToday: Double = 0.0
    @Published var dailyGoal: Double = 0.0
   
    @Published var percentage: Double = 0.0
    @Published var showAlert: Bool = false
    @Published var isDrinking: Bool = false
    @Published var completed: Bool = false
    @Published var showCompleted: Bool = false
    
    @Published var examineSetting: Bool = false
    
    @Published var showUserSetting: Bool = false
    
    @Published var launchedBefore: Bool = true
    
    init(){
        timerPublisher.connect().store(in: &cancellables)
        drankToday = userProfile.todayRecord?.drankToday ?? 0
        dailyGoal = userProfile.dailyGoal
        showAlert = (userProfile.dailyGoal == 0) || (userProfile.speed == 0)
        launchedBefore = userProfile.launchedBefore
        
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
                guard let self = self else { return }
                self.drankToday += 0.2 * (self.userProfile.speed) / 1000
                let drankToday = self.drankToday
                let dailyGoal = self.userProfile.dailyGoal
                if dailyGoal != 0 {
                    self.percentage = drankToday / dailyGoal
                    self.userProfile.todayRecord?.drankToday = drankToday
                }
                if !self.launchedBefore {
                    self.launchedBefore.toggle()
                    self.userProfile.launchedBefore.toggle()
                }
                self.userProfile.updateRecord = true
                AppState.shared.updateCalendar = true
            }
            .store(in: &cancellables)
        
        self.$percentage
            .filter { $0 >= 1 }
            .sink { [weak self] _ in
                if let alreadyComp = self?.userProfile.completedToday, alreadyComp == false {
                    self?.completed = true
                    self?.userProfile.completedToday = true
                }
            }
            .store(in: &cancellables)
        
        self.$completed
            .combineLatest(self.$isDrinking)
            .filter { $0 && !$1 }
            .sink { [weak self] _ in
                self?.showCompleted = true
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
    }
}

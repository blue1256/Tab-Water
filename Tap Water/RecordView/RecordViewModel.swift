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
    
    @Published var drankToday: Double = 0.0
    @Published var dailyGoal: Double = 0.0
   
    @Published var percentage: Double = 0.0
    @Published var showAlert: Bool = false
    @Published var isDrinking: Bool = false
    @Published var showCompleted: Bool = false
    
    @Published var examineSetting: Bool = false
    
    @Published var showUserSetting: Bool = false
    
    @Published var launchedBefore: Bool = true
    
    init(){
        timerPublisher.connect().store(in: &cancellables)
        drankToday = UserProfile.shared.todayRecord?.drankToday ?? 0
        dailyGoal = UserProfile.shared.dailyGoal
        showAlert = (UserProfile.shared.dailyGoal == 0) || (UserProfile.shared.speed == 0)
        launchedBefore = AppState.shared.launchedBefore
        
        UserProfile.shared.$todayRecord
            .sink { [weak self] record in
                guard let self = self else { return }
                let drankToday = record?.drankToday ?? 0
                self.drankToday = drankToday
                self.percentage = drankToday / self.dailyGoal
            }
            .store(in: &cancellables)
        
        UserProfile.shared.$dailyGoal
            .removeDuplicates()
            .sink { [weak self] goal in
                guard let self = self else { return }
                if self.dailyGoal != 0 {
                    self.percentage = self.drankToday / self.dailyGoal
                }
            }
            .store(in: &cancellables)
        
        self.$isDrinking
            .combineLatest(timerPublisher)
            .map { return $0.0 }
            .filter{ $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.drankToday += 0.1 * (UserProfile.shared.speed) / 1000
                let drankToday = self.drankToday
                let dailyGoal = UserProfile.shared.dailyGoal
                if dailyGoal != 0 {
                    self.percentage = drankToday / dailyGoal
                    UserProfile.shared.todayRecord?.drankToday = drankToday
                }
                if !self.launchedBefore {
                    self.launchedBefore.toggle()
                    AppState.shared.launchedBefore.toggle()
                }
                UserProfile.shared.updateRecord = true
                AppState.shared.updateCalendar = true
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
                self.showAlert = (UserProfile.shared.dailyGoal == 0) || (UserProfile.shared.speed == 0)
            }
            .store(in: &cancellables)
    }
}

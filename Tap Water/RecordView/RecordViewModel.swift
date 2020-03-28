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
    
    init(){
        timerPublisher.connect().store(in: &cancellables)
        drankToday = userProfile.drankToday
        dailyGoal = userProfile.dailyGoal
        showAlert = (userProfile.dailyGoal == 0) || (userProfile.speed == 0)
        
        userProfile.$dailyGoal
            .removeDuplicates()
            .sink { [weak self] goal in
                self?.dailyGoal = goal
                if let drankToday = self?.drankToday, goal != 0 {
                    self?.percentage = drankToday / goal
                }
            }
            .store(in: &cancellables)
        
        userProfile.$drankToday
            .removeDuplicates()
            .sink { [weak self] drank in
                self?.drankToday = drank
                if let dailyGoal = self?.userProfile.dailyGoal, dailyGoal != 0 {
                    self?.percentage = drank / dailyGoal
                }
            }
            .store(in: &cancellables)
        
        self.$isDrinking
            .combineLatest(timerPublisher)
            .map { return $0.0 }
            .filter{ $0 }
            .sink { [weak self] _ in
                self!.userProfile.drankToday += 0.3 * self!.userProfile.speed / 1000
            }
            .store(in: &cancellables)
        
        self.$percentage
            .filter { $0 >= 1 }
            .first()
            .sink { _ in
                self.completed = true
            }
            .store(in: &cancellables)
        
        self.$completed
            .combineLatest(self.$isDrinking)
            .filter { $0 && !$1 }
            .first()
            .sink { _ in
                self.showCompleted = true
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

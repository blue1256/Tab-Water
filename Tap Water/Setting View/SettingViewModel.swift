//
//  SettingViewModel.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/06.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import Combine

class SettingViewModel: ObservableObject {
    var userProfile = UserProfile.shared
    var appState = AppState.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Setting View
    @Published var showUserSetting: Bool = false
    @Published var showAppInfo: Bool = false
    @Published var showSpeedMeasure: Bool = false
    @Published var showRecordDeletionSheet: Bool = false
    @Published var deleteAllRecord: Bool = false
    
    // Record Setting View
    @Published var goalPickerValue: Int = 0
    @Published var showSaveButton: Bool = false
    @Published var showPicker: Bool = false
    @Published var showGoalAlert: Bool = false
    
    init() {
        goalPickerValue = Int(userProfile.dailyGoal*10)
        
        appState.$showUserSetting
            .sink { [weak self] show in
                guard let self = self else { return }
                self.showUserSetting = show
            }
            .store(in: &cancellables)
        
        self.$goalPickerValue
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink{ [weak self] val in
                guard let self = self else { return }
                if self.userProfile.dailyGoal != Double(val) / 10.0 {
                    self.showSaveButton = true
                } else {
                    self.showSaveButton = false
                }
            }
            .store(in: &cancellables)
            
        
        self.$showPicker
            .filter { !$0 }
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.userProfile.dailyGoal != Double(self.goalPickerValue) / 10.0 {
                    self.showGoalAlert = true
                }
                self.userProfile.dailyGoal = Double(self.goalPickerValue) / 10.0
                self.showSaveButton = false
            }
            .store(in: &cancellables)
        
        self.$deleteAllRecord
            .filter{ $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                StoreManager.shared.deleteAll()
                AppState.shared.deleteCalendar = true
                self.deleteAllRecord = false
            }
            .store(in: &cancellables)
    }
}

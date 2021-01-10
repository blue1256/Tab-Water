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
    private var cancellables = Set<AnyCancellable>()
    
    // Setting View
    @Published var updateAvailable: String = AppState.shared.isUpdateAvailable() ? "UpdateAvailable".localized : ""
    @Published var showAppInfo: Bool = false
    @Published var showSpeedMeasure: Bool = false
    @Published var showRecordDeletionSheet: Bool = false
    @Published var deleteAllRecord: Bool = false
    @Published var notification: Bool = false
    @Published var speed: Double = 0.0
    
    // Record Setting View
    @Published var goalPickerValue: Int = 0
    @Published var showGoalSaveButton: Bool = false
    @Published var showGoalPicker: Bool = false
    @Published var showGoalAlert: Bool = false
    var dailyGoal: Double = 0.0
    
    // Reminder  Setting View
    @Published var timePickerValue: Int = 0
    @Published var showTimePicker: Bool = false
    @Published var showTimeSaveButton: Bool = false
    @Published var showTimeAlert: Bool = false
    
    init() {
        dailyGoal = UserDefaults.standard.double(forKey: "dailyGoal")
        speed = UserDefaults.standard.double(forKey: "speed")
        goalPickerValue = Int(dailyGoal*10)
        timePickerValue = AppState.shared.remindingTime - 1
        
        notification = AppState.shared.enabledNotification
        
        self.$goalPickerValue
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink{ [weak self] val in
                guard let self = self else { return }
                if self.dailyGoal != Double(val) / 10.0 {
                    self.showGoalSaveButton = true
                } else {
                    self.showGoalSaveButton = false
                }
            }
            .store(in: &cancellables)
            
        self.$showGoalPicker
            .filter { !$0 }
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.dailyGoal != Double(self.goalPickerValue) / 10.0 {
                    self.showGoalAlert = true
                }
                let todayRecord = StoreManager.shared.getTodayRecord()
                if let record = todayRecord {
                    record.dailyGoal = Double(self.goalPickerValue) / 10.0
                    StoreManager.shared.setTodayRecord(record)
                }
                UserDefaults.standard.set(Double(self.goalPickerValue) / 10.0, forKey: "dailyGoal")
                self.dailyGoal = Double(self.goalPickerValue) / 10.0
                self.showGoalSaveButton = false
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
        
        self.$notification
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink { notification in
                AppState.shared.enabledNotification = notification
            }
            .store(in: &cancellables)
        
        self.$timePickerValue
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { [weak self] val in
                guard let self = self else { return }
                if AppState.shared.remindingTime != val+1 {
                    self.showTimeSaveButton = true
                } else {
                    self.showTimeSaveButton = false
                }
            }
            .store(in: &cancellables)
        
        self.$showTimePicker
            .filter{ !$0 }
            .dropFirst()
            .sink{ [weak self] _ in
                guard let self = self else { return }
                if AppState.shared.remindingTime != self.timePickerValue+1 {
                    self.showTimeAlert = true
                }
                AppState.shared.remindingTime = self.timePickerValue+1
                self.showTimeSaveButton = false
            }
            .store(in: &cancellables)
    }
}

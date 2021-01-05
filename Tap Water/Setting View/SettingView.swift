//
//  SettingView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/24.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

private extension SettingView {
    var appInfoSection: some View {
        Section(header: Text("AboutCategory".localized)) {
            NavigationLink(destination: AppInfoView(settingViewModel: settingViewModel), isActive: $settingViewModel.showAppInfo) {
                HStack {
                    Text("AppInfo".localized)
                    Spacer()
                    Text(settingViewModel.updateAvailable)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    var notificationSection: some View {
        Section(header: Text("NotificationCategory".localized)) {
            Toggle(isOn: $settingViewModel.notification) {
                Text("Reminder".localized)
            }
            
            Button(action: {
                withAnimation {
                    self.settingViewModel.showTimePicker.toggle()
                }
            }) {
                HStack {
                    Text("Interval".localized)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    if settingViewModel.showTimeSaveButton {
                        Text("Save".localized)
                            .foregroundColor(.blue)
                    } else {
                        HStack {
                            if !settingViewModel.showTimePicker {
                                Text("HourFormat".localized( self.settingViewModel.timePickerValue+1))
                                    .foregroundColor(.gray)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(red: 196/255, green: 196/255, blue: 196/255))
                                .imageScale(.small)
                                .rotationEffect(.degrees(settingViewModel.showTimePicker ? 90 : 0))
                        }
                    }
                }
            }
            .padding([.top, .bottom], 8)
            
            if settingViewModel.showTimePicker {
                Picker(selection: $settingViewModel.timePickerValue, label: Text("")) {
                    ForEach(1..<25) {
                        Text("HourFormat".localized($0))
                    }
                }
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .pickerStyle(WheelPickerStyle())
            }
        }
    }
    
    var recordSection: some View {
        Section(header: Text("RecordCategory".localized)) {
            Button(action: {
                withAnimation {
                    self.settingViewModel.showGoalPicker.toggle()
                }
            }) {
                HStack {
                    Text("DailyGoal".localized)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    if settingViewModel.showGoalSaveButton {
                        Text("Save".localized)
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(red: 196/255, green: 196/255, blue: 196/255))
                            .imageScale(.small)
                            .rotationEffect(.degrees(settingViewModel.showGoalPicker ? 90 : 0))
                    }
                }
            }
            
            if settingViewModel.showGoalPicker {
                Picker(selection: self.$settingViewModel.goalPickerValue, label: Text("")) {
                    ForEach(0..<51) {
                        Text("\(Utils.shared.floorDouble(num: Double($0)/10.0))L")
                    }
                }
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .pickerStyle(WheelPickerStyle())
            }
            
            Button(action: {
                withAnimation {
                    self.settingViewModel.showSpeedMeasure = true
                }
            }) {
                HStack {
                    Text("DrinkingSpeed".localized)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(red: 196/255, green: 196/255, blue: 196/255))
                        .imageScale(.small)
                }
            }
            
            Button(action: {
                self.settingViewModel.showRecordDeletionSheet = true
            }) {
                Text("ClearRecords".localized)
                    .foregroundColor(.black)
            }
        }
    }
}

struct SettingView: View {
    @ObservedObject var settingViewModel = SettingViewModel()
    
    var body: some View {
        NavigationView {
            List {
                recordSection
                    .alert(isPresented: $settingViewModel.showGoalAlert) {
                        Alert(title: Text("DailyGoal".localized),
                              message: Text("GoalSetContent".localized),
                              dismissButton: .default(Text("Confirm".localized))
                        )
                    }
                
                notificationSection
                    .alert(isPresented: $settingViewModel.showTimeAlert) {
                        Alert(title: Text("Interval".localized),
                              message: Text("IntervalSetContent".localized),
                              dismissButton: .default(Text("Confirm".localized))
                        )
                    }
                
                appInfoSection
            }
            .id(UUID())
            .transition(.opacity)
            .listStyle(GroupedListStyle())
            .environment(\.defaultMinListRowHeight, 50)
            .navigationBarTitle(Text("Settings".localized), displayMode: .inline)
            .actionSheet(isPresented: $settingViewModel.showRecordDeletionSheet) {
                let delete = ActionSheet.Button.destructive(Text("ClearRecords".localized)) {
                    self.settingViewModel.deleteAllRecord = true
                }
                let cancel = ActionSheet.Button.cancel(Text("Cancel".localized))
                let sheet = ActionSheet(title: Text(""), message: Text("ClearRecordsContent".localized), buttons: [delete, cancel])
                return sheet
            }
            .sheet(isPresented: $settingViewModel.showSpeedMeasure) {
                SpeedMeasureView(settingViewModel: self.settingViewModel)
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

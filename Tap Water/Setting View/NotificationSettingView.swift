//
//  ReminderSettingView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/08/27.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

private extension NotificationSettingView {
    var notificationToggleSection: some View {
        Section {
            Toggle(isOn: $settingViewModel.notification) {
                Text("리마인더")
            }
        }
    }
    
    var timePickerSection: some View {
        Section {
            Button(action: {
                withAnimation {
                    self.settingViewModel.showTimePicker.toggle()
                }
            }) {
                HStack {
                    Text("시간 설정")
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    if settingViewModel.showTimeSaveButton {
                        Text("저장")
                            .foregroundColor(.blue)
                    } else {
                        HStack {
                            Text((settingViewModel.showTimePicker ? "         " : "\(self.settingViewModel.timePickerValue+1)시간"))
                                .foregroundColor(.gray)
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
                        Text("\($0)시간")
                    }
                }
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .pickerStyle(WheelPickerStyle())
            }
        }
    }
}

struct NotificationSettingView: View {
    @ObservedObject var settingViewModel: SettingViewModel
    
    var body: some View {
        List {
            notificationToggleSection
            
            timePickerSection
        }
        .listStyle(GroupedListStyle())
        .environment(\.defaultMinListRowHeight, 50)
        .navigationBarTitle("리마인더", displayMode: .inline)
        .alert(isPresented: $settingViewModel.showTimeAlert) {
            Alert(title: Text("시간 설정"),
                  message: Text("시간이 변경되었습니다."),
                  dismissButton: .default(Text("확인"))
            )
        }
    }
}

struct NotificationSettingView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingView(settingViewModel: SettingViewModel())
    }
}

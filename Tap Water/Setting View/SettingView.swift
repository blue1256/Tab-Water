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
        Section {
            NavigationLink(destination: AppInfoView(settingViewModel: settingViewModel), isActive: $settingViewModel.showAppInfo) {
                HStack {
                    Text("앱 정보")
                    Spacer()
                    Text(settingViewModel.updateAvailable)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    var notificationSection: some View {
        Section {
            NavigationLink(destination: NotificationSettingView(settingViewModel: settingViewModel), isActive: $settingViewModel.showReminderSetting) {
                Text("알림 설정")
            }
        }
    }
    
    var recordSection: some View {
        Section {
            NavigationLink(destination: RecordSettingView(settingViewModel: settingViewModel), isActive: $settingViewModel.showUserSetting) {
                Text("기록 설정")
            }
            Button(action: {
                self.settingViewModel.showRecordDeletionSheet = true
            }) {
                Text("기록 삭제")
            }
        }
    }
}

struct SettingView: View {
    @ObservedObject var settingViewModel = SettingViewModel()
    
    var body: some View {
        NavigationView {
            List {
                appInfoSection
                
                notificationSection
                
                recordSection
            }
            .listStyle(GroupedListStyle())
            .environment(\.defaultMinListRowHeight, 50)
            .navigationBarTitle(Text("설정"), displayMode: .large)
            .actionSheet(isPresented: $settingViewModel.showRecordDeletionSheet) {
                let delete = ActionSheet.Button.destructive(Text("기록 삭제")) {
                    self.settingViewModel.deleteAllRecord = true
                }
                let cancel = ActionSheet.Button.cancel(Text("취소"))
                let sheet = ActionSheet(title: Text(""), message: Text("현재까지의 모든 물 기록량을 삭제합니다."), buttons: [delete, cancel])
                return sheet
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

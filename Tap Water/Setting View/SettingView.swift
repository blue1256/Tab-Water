//
//  SettingView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/24.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject var settingViewModel = SettingViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("개발자 정보")
                }
                Section {
                    NavigationLink(destination: UserSettingView(settingViewModel: settingViewModel), isActive: $settingViewModel.showUserSetting) {
                        Text("사용자 설정")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.defaultMinListRowHeight, 50)
            .navigationBarTitle(Text("설정"), displayMode: .large)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

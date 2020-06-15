//
//  AppInfoView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/06/12.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct AppInfoView: View {
    @ObservedObject var settingViewModel: SettingViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            Text("Tap Water")
                .font(.largeTitle)
            Image("water")
                .resizable()
                .frame(width: 150, height: 150)
            Spacer()
            Text(AppState.shared.isUpdateAvailable() ? "최신 버전 업데이트가 가능합니다."
                : "최신 버전 사용중입니다.")
                .padding(5)
            Text("현재 버전: \(AppState.shared.version)")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Text("최신 버전: \(AppState.shared.appStoreVersion)")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView(settingViewModel: SettingViewModel())
    }
}

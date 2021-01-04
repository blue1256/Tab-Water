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
    @State var updateAvailable = AppState.shared.isUpdateAvailable()
    
    let waterColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Tap Water")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(self.waterColor)
            
            Spacer()
            
            Image("InfoIcon")
            
            Spacer()
            
            Text(updateAvailable ? "최신 버전 업데이트가 가능합니다"
                : "최신 버전 사용중입니다")
                .padding(5)
            Text("현재 버전: \(AppState.shared.version)")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Text("최신 버전: \(AppState.shared.appStoreVersion)")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationBarTitle("앱 정보", displayMode: .inline)
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView(settingViewModel: SettingViewModel())
    }
}

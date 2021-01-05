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
            
            Text(updateAvailable ? "UpdateIsAvailable".localized : "UpToDate".localized)
                .padding(5)
            Text("\("CurrentVersion".localized): \(AppState.shared.version)")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            Text("\("LatestVersion".localized): \(AppState.shared.appStoreVersion)")
                .font(.system(size: 15))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationBarTitle(Text("AppInfo".localized), displayMode: .inline)
    }
}

struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView(settingViewModel: SettingViewModel())
    }
}

//
//  SpeedMeasureView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/25.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct SpeedMeasureView: View {
    @ObservedObject var settingViewModel: SettingViewModel
    
    var body: some View {
        HStack {
            TextField("속도 입력", text: $settingViewModel.fieldInput)
                .border(Color.gray)
                .padding()
            
            Button(action: {
                self.settingViewModel.saveSpeed = true
            }) {
                Text("확인")
            }
            .padding(.trailing, 20)
        }
    }
}

struct SpeedMeasureView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedMeasureView(settingViewModel: SettingViewModel())
    }
}

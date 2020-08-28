//
//  UserSettingView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/15.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct RecordSettingView: View {
    @ObservedObject var settingViewModel: SettingViewModel
    
    var body: some View {
        List {
            Button(action: {
                withAnimation {
                    self.settingViewModel.showGoalPicker.toggle()
                }
            }) {
                HStack {
                    Text("하루 목표 설정")
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    if settingViewModel.showGoalSaveButton {
                        Text("저장")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(red: 196/255, green: 196/255, blue: 196/255))
                            .imageScale(.small)
                            .rotationEffect(.degrees(settingViewModel.showGoalPicker ? 90 : 0))
                    }
                }
            }
            .padding([.top, .bottom], 8)
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
                    Text("속도 재설정")
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(red: 196/255, green: 196/255, blue: 196/255))
                        .imageScale(.small)
                }
            }
        }
        .navigationBarTitle(Text("기록 설정"), displayMode: .inline)
        .alert(isPresented: $settingViewModel.showGoalAlert) {
            Alert(title: Text("목표 설정"),
                  message: Text("목표가 변경되었습니다."),
                  dismissButton: .default(Text("확인"))
            )
        }
        .sheet(isPresented: $settingViewModel.showSpeedMeasure) {
            SpeedMeasureView(settingViewModel: self.settingViewModel)
        }
    }
}

struct UserSettingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordSettingView(settingViewModel: SettingViewModel())
    }
}

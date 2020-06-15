//
//  StartView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/06/07.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var startViewModel = StartViewModel()
    let startColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    let endColor = Color.init(red: 244/255, green: 245/255, blue: 255/255)
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: .init(colors: [self.startColor, self.endColor]),
                    startPoint: .init(x: 0.5, y: 0),
                    endPoint: .init(x: 0.5, y: 1)
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Text("Tap Water")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, -50)
                    Spacer()
                    Picker(selection: self.$startViewModel.goalPickerValue, label: Text("")) {
                        ForEach(0..<51) {
                            Text("\(Utils.shared.floorDouble(num: Double($0)/10.0))L")
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    
                    Text("하루 목표량을 설정해주세요.")
                        .font(.system(size: 15))
                        .padding(.bottom, 40)
                    
                    Spacer()
                    
                    NavigationLink(destination: SpeedMeasureView(), isActive: $startViewModel.saveGoal) {
                        HStack {
                            Text("목표 설정 완료")
                                .font(.system(size: 22))
                                .foregroundColor(self.startColor)
                            Image(systemName: "arrow.right.circle")
                                .font(.system(size: 22))
                                .foregroundColor(self.startColor)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}

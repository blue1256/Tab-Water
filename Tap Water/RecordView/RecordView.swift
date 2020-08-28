//
//  RecordView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/24.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct RecordView: View {
    @ObservedObject var recordViewModel = RecordViewModel()
    
    var animation: Animation {
        return Animation.easeInOut(duration: 2).repeatForever()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack{
                    WaterBackground(percentage: self.recordViewModel.percentage)
                }
                VStack {
                    Spacer()
                    VStack {
                        Text("\(Utils.shared.floorDouble(num: self.recordViewModel.percentage*100))%")
                            .font(.custom("bold", size: 50))
                            .padding(.bottom)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.init(red: 52/255, green: 172/255, blue: 221/255))
                            .hueRotation(Angle(degrees: 90 * self.recordViewModel.percentage))
                            .animation(nil)
                        Text("현재: \(Utils.shared.floorDouble(num: self.recordViewModel.drankToday))L")
                            .padding(.bottom, 10)
                            .frame(maxWidth: .infinity)
                            .animation(nil)
                        Text("목표: \(Utils.shared.floorDouble(num: self.recordViewModel.dailyGoal))L")
                            .frame(maxWidth: .infinity)
                            .animation(nil)
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.recordViewModel.isDrinking.toggle()
                        }
                    }) {
                        Image(
                            systemName: (self.recordViewModel.isDrinking ? "stop.fill" : "plus"))
                            .foregroundColor(.white)
                            .font(.custom("", size: 30))
                            .padding(15)
                    }
                    .background(Color.init(red: 52/255, green: 172/255, blue: 221/255))
                    .hueRotation(Angle(degrees: 90 * self.recordViewModel.percentage.truncatingRemainder(dividingBy: 1)))
                    .clipShape(Circle())
                    Spacer()
                }
            }
            .onAppear(perform: {
                self.recordViewModel.examineSetting = true
                AppState.shared.requestNotification()
            })
            .sheet(isPresented: self.$recordViewModel.showCompleted) {
                CompletedView(recordViewModel: self.recordViewModel)
            }
            .alert(isPresented: self.$recordViewModel.showAlert) {
                Alert(
                    title: Text("설정 오류"),
                    message: Text("목표량 또는 속도가 설정되지 않았습니다."),
                    dismissButton: .default(Text("확인"), action: {
                        self.recordViewModel.showUserSetting = true
                    })
                )
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}

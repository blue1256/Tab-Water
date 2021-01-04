//
//  RecordView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/24.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

private extension RecordView {
    
    var mainInfoText: some View {
        VStack {
            Text("\(Utils.shared.floorDouble(num: self.recordViewModel.percentage*100))%")
                .font(.custom("bold", size: 50))
                .padding(.bottom)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.init(red: 125/255, green: 175/255, blue: 235/255))
                .animation(nil)
            Text("현재: \(Utils.shared.floorDouble(num: self.recordViewModel.drankToday))L")
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .animation(nil)
            Text("목표: \(Utils.shared.floorDouble(num: self.recordViewModel.dailyGoal))L")
                .frame(maxWidth: .infinity)
                .animation(nil)
        }
    }
    
    var drinkButton: some View {
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
        .background(Color.init(red: 125/255, green: 175/255, blue: 235/255))
        .clipShape(Circle())
    }
    
    var guideText: some View {
        Text("물을 마시기 시작하며 버튼을 누르고\n다 마신 뒤 버튼을 다시 눌러주세요.")
            .font(.system(size: 15))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }
}

struct RecordView: View {
    @ObservedObject var recordViewModel = RecordViewModel()
    
    var animation: Animation {
        return Animation.easeInOut(duration: 2).repeatForever()
    }

    var body: some View {
        ZStack {
            VStack{
                WaterBackground(percentage: min(self.recordViewModel.percentage, 1))
            }
            VStack {
                Spacer()
                
                mainInfoText
                
                Spacer()
                
                drinkButton
                
                if !self.recordViewModel.launchedBefore {
                    guideText.padding(.top, 20)
                }
                
                Spacer()
            }
        }
        .onAppear(perform: {
            self.recordViewModel.examineSetting = true
            self.recordViewModel.initializeRecord()
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

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}

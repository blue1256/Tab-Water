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
                .font(.custom("bold", size: 55))
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.init(red: 125/255, green: 175/255, blue: 235/255))
                .animation(nil)
            Text("\("Current".localized): \(Utils.shared.floorDouble(num: self.recordViewModel.drankToday))L")
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
                .animation(nil)
            Text("\("Goal".localized): \(Utils.shared.floorDouble(num: self.recordViewModel.dailyGoal))L")
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
        Text("RecordHelp".localized)
            .font(.system(size: 15))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }
}

struct RecordView: View {
    @ObservedObject var recordViewModel = RecordViewModel()

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
                title: Text("RecordSettingsError".localized),
                message: Text("RecordSettingsErrorContent".localized),
                dismissButton: .default(Text("Confirm".localized), action: {
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

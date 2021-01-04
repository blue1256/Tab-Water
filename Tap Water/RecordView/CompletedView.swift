//
//  CompletedView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/05/17.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

private extension CompletedView {
    var completeText: some View {
        Text("목표 달성!")
            .font(.system(size: 30))
            .fontWeight(.bold)
    }
    
    var confirmButton: some View {
        Button(action: {
            self.recordViewModel.showCompleted = false
        }) {
            VStack {
                Image(systemName: "checkmark")
                    .font(.system(size: 25))
                    .foregroundColor(self.waterColor)
                Text("확인")
                    .font(.system(size: 25))
                    .foregroundColor(self.waterColor)
            }
        }
    }
    
    var summaryButton: some View {
        Button(action: {
            AppState.shared.selectedTab = 0
            self.recordViewModel.showCompleted = false
        }) {
            VStack {
                Image("summary")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .scaleEffect(1.3)
                    .foregroundColor(self.waterColor)
                Text("달력 보기")
                    .font(.system(size: 25))
                    .foregroundColor(self.waterColor)
            }
        }
    }
}

struct CompletedView: View {
    @ObservedObject var recordViewModel: RecordViewModel
    let waterColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.init(red: 216/255, green: 236/255, blue: 233/255)
                VStack {
                    completeText
                    
                    Image("trophy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.7)
                    
                    HStack {
                        Spacer()
                        
                        confirmButton
                        
                        Spacer()
                        
                        summaryButton
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

struct CompletedView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedView(recordViewModel: RecordViewModel())
    }
}

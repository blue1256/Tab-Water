//
//  SummaryView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/24.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

private extension SummaryView {
    var upperBanner: some View {
        HStack {
            Text("\(self.summaryViewModel.monthTitle)")
                .font(.system(size: 30, weight: .semibold))
                .padding()
            Spacer()
            Button(action: {
                self.summaryViewModel.showStats = true
            }, label: {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.gray)
            })
            .padding()
        }
    }
    
    var dayInfoSection: some View {
        GeometryReader { geometry in
            HStack {
                Text("\(self.summaryViewModel.selectedDateInString)")
                    .multilineTextAlignment(.leading)
                    .frame(width: geometry.size.width*0.25)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.trailing, -8)
                Divider()
                VStack(alignment: .leading) {
                    if let selectedRecord = self.summaryViewModel.selectedRecord, selectedRecord.drankToday != 0.0 {
                        let drankToday = selectedRecord.drankToday
                        let dailyGoal = selectedRecord.dailyGoal
                        
                        Text("\(Utils.shared.floorDouble(num: drankToday / dailyGoal * 100))%")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(waterColor)
                            .padding(.bottom, 1)
                        Text("\("Drank".localized): \(Utils.shared.floorDouble(num: drankToday))L")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        Text("\("Goal".localized): \(Utils.shared.floorDouble(num: dailyGoal))L")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    } else {
                        Text("NoRecord".localized)
                            .padding(.bottom, 2)
                        Text("NoRecordContent".localized)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
        }
    }
}

struct SummaryView: View {
    @ObservedObject var summaryViewModel = SummaryViewModel()
    
    let waterColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                upperBanner
                
                CalendarView(summaryViewModel: self.summaryViewModel)
                    .frame(height: geometry.size.height*0.65)
                
                Divider()
                
                dayInfoSection
                    .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: self.$summaryViewModel.showStats) {
            StatsView()
        }
        .onAppear {
            summaryViewModel.refreshToday()
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

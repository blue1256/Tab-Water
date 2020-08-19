//
//  ContentView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/24.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var contentViewModel = ContentViewModel()
    
    var transition: AnyTransition {
        return AnyTransition.opacity.animation(.easeInOut(duration: 0.14))
    }
    
    var summary = SummaryView()
    var record = RecordView()
    var setting = SettingView()
 
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if self.contentViewModel.selectedTab == 0 {
                    self.summary
                        .padding(.bottom, -5)
                        .transition(self.transition)
                } else if self.contentViewModel.selectedTab == 1 {
                    self.record
                        .padding(.bottom, -5)
                        .transition(self.transition)
                } else if self.contentViewModel.selectedTab == 2 {
                    self.setting
                        .transition(self.transition)
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.contentViewModel.selectedTab = 0
                        }
                    }) {
                        Image((self.contentViewModel.selectedTab == 0 ? "summary" : "summary-disabled"))
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.contentViewModel.selectedTab = 1
                        }
                    }) {
                        Image((self.contentViewModel.selectedTab == 1 ? "water" : "water-disabled"))
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.contentViewModel.selectedTab = 2
                        }
                    }) {
                        Image((self.contentViewModel.selectedTab == 2 ? "setting" : "setting-disabled"))
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.leading, 30)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    Spacer()
                }
                .frame(width: geometry.size.width, height: 50 + geometry.safeAreaInsets.bottom)
                .background(Color.white.shadow(color: .init(white: 0.9), radius: 2, x: 0, y: -3.5))
                .padding(.top, -5)
                .padding(.bottom, -geometry.safeAreaInsets.bottom)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/24.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 1
    
    var transition: AnyTransition {
        return AnyTransition.opacity.animation(.easeInOut(duration: 0.14))
    }
 
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                if self.selection == 0 {
                    SummaryView()
                        .transition(self.transition)
                } else if self.selection == 1 {
                    RecordView()
                        .transition(self.transition)
                } else if self.selection == 2 {
                    SettingView()
                        .transition(self.transition)
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.selection = 0
                        }
                    }) {
                        Image((self.selection == 0 ? "summary" : "summary-disabled"))
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.selection = 1
                        }
                    }) {
                        Image((self.selection == 1 ? "water" : "water-disabled"))
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.selection = 2
                        }
                    }) {
                        Image((self.selection == 2 ? "setting" : "setting-disabled"))
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

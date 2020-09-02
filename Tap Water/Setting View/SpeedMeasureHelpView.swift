//
//  SpeedMeasureHelpView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/09/02.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct SpeedMeasureHelpView: View {
    let waterColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("마실 양")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(waterColor)
                    .padding(.top, 20)
                
                Text("속도 측정을 위해 앱의 첫 실행 시에 사용자가 마실 정확한 양을 알아야 합니다.\n\n속도 평균을 내기 위해 세 번에 걸쳐 마시게 되므로 부담이 되지 않는 양으로 설정해주세요.")
                    .padding(.top, 15)
                
                Text("유용한 각종 컵 용량 정보")
                    .font(.headline)
                    .foregroundColor(waterColor)
                    .padding(.top, 30)
                
                HStack(alignment: .bottom) {
                    Spacer()
                    VStack {
                        Image("paperbag-cup")
                        Text("종이봉투컵: 45ml")
                            .font(.system(size: 13))
                    }
                    Spacer()
                    VStack {
                        Image("soju-cup")
                        Text("소주잔: 50ml")
                            .font(.system(size: 13))
                    }
                    Spacer()
                    VStack {
                        Image("paper-cup")
                        Text("일반종이컵: 160ml")
                            .font(.system(size: 13))
                    }
                    Spacer()
                }
                
                HStack(alignment: .bottom) {
                    Spacer()
                    VStack {
                        Image("home-cup")
                        Text("가정용 물컵: 190ml")
                            .font(.system(size: 13))
                            .padding(.trailing, 20)
                    }
                    VStack {
                        Image("glass-cup")
                        Text("맥주 글라스: 180ml")
                            .font(.system(size: 13))
                    }
                    Spacer()
                }
                Text("각 용량은 가득 채운 것이 아닌 적정 용량을 채운 기준입니다.")
                    .font(.system(size: 13))
                    .padding(.top, 30)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
            .padding()
        }
    }
}

struct SpeedMeasureHelpView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedMeasureHelpView()
    }
}

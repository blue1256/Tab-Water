//
//  CirclePercentageView.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/10.
//  Copyright © 2021 박종석. All rights reserved.
//

import SwiftUI

struct CirclePercentageView: View {
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    private let waterColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    @State var drewPercentage: Double = 0
    var percentage: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .foregroundColor(.init(white: 235/255))
                    .frame(width: geometry.size.width-20)
                
                Path { path in
                    path.addArc(
                        center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                        radius: geometry.size.width/2-10,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * drewPercentage),
                        clockwise: false)
                }
                .strokedPath(.init(lineWidth: 10, lineCap: .square))
                .foregroundColor(waterColor)
                .rotationEffect(.degrees(-90))
                
                Text(String(format: "%.1f%%", percentage * 100))
                    .font(.system(size: 50))
                    .foregroundColor(waterColor)
            }
        }
        .onReceive(timer) { _ in
            if drewPercentage < percentage {
                self.drewPercentage += percentage / 60
            }
        }
    }
}

struct CirclePercentageView_Previews: PreviewProvider {
    static var previews: some View {
        CirclePercentageView(percentage: 0.612)
    }
}

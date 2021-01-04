//
//  RecordBackground.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/26.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct WaterBackground: View {
    var timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    var percentage: Double
    @State var elapsed = 0.0
    
    let waterColor = Color.init(red: 125/255, green: 175/255, blue: 235/255, opacity: 0.6)
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height * CGFloat(self.percentage * 1.05)
                let waveCount = 5
                let waveHeight = (self.percentage == 0 ? 0.0 : 5.0)
                path.move(to: .init(x: 0, y: height))
                path.addLine(to: .init(x: 0, y: sin(self.elapsed) * waveHeight))
                var prevX = 0.0
                var prevY = sin(self.elapsed) * waveHeight
                (1...waveCount+1).forEach { i in
                    let x = Double(i)/(Double(waveCount)) * Double(width)
                    let y = sin(Double(i) + self.elapsed) * waveHeight
                    path.addQuadCurve(to: .init(x: (prevX+x)/2, y: (prevY+y)/2), control: .init(x: prevX, y: prevY))
                    prevX = x
                    prevY = y
                }
                path.addLine(to: .init(x: width, y: height))
                path.addLine(to: .init(x: 0, y: height))
            }
            .fill(waterColor)
            .position(x: geometry.size.width/2, y: geometry.size.height*(1.5-CGFloat(self.percentage) * 1.05))
            .transition(.move(edge: .bottom))
            .animation(.easeInOut(duration: 0.5))
            .onReceive(self.timer) { _ in
                self.elapsed += 0.08
            }
        }
    }
}

struct WaterBackground_Previews: PreviewProvider {
    static var previews: some View {
        WaterBackground(percentage: 0.6)
    }
}

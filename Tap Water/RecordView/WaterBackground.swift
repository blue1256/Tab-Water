//
//  RecordBackground.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/26.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct WaterBackground: View {
    var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    var HTimer = Timer.publish(every: 0.07, on: .main, in: .common).autoconnect()
    var percentage: Double
    @State var elapsed = 0.0
    @State var heightMult = 0.0
    var mult: [Double] {
        var m = [Double]()
        for i in (-20...20) {
            m.append(Double(i)/20.0)
        }
        for i in (-19...19) {
            m.append(-Double(i)/20.0)
        }
        return m
    }
    
    let startColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    let endColor = Color.init(red: 244/255, green: 245/255, blue: 255/255)
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height * CGFloat(self.percentage * 1.05)
                let waveCount = 1000
                let waveHeight = (self.percentage == 0 ? 0 : 5) * self.mult[Int(self.heightMult) % 80]
                path.move(to: .init(x: 0, y: height))
                path.addLine(to: .init(x: 0, y: Double(waveHeight) + sin(Double(self.elapsed) * 0.5)))
                (1...waveCount).forEach { i in
                    let x = Double(i) / Double(waveCount) * Double(width)
                    let y = sin((Double(i) + self.elapsed * 5) * 0.006) * Double(waveHeight)
                    path.addLine(to: .init(x: x, y: y))
                }
                path.addLine(to: .init(x: width, y: height))
                path.addLine(to: .init(x: 0, y: height))
            }
            .fill(LinearGradient(
                gradient: .init(colors: [self.startColor, self.endColor]),
                startPoint: .init(x: 0.5, y: 0),
                endPoint: .init(x: 0.5, y: 1)
            ))
            .position(x: geometry.size.width/2, y: geometry.size.height*(1.5-CGFloat(self.percentage) * 1.05))
            .transition(.move(edge: .bottom))
            .animation(.easeInOut(duration: 0.5))
            .onReceive(self.timer) { _ in
                self.elapsed += 3
            }
            .onReceive(self.HTimer) { _ in
                self.heightMult += 1
            }
        }
    }
}

struct WaterBackground_Previews: PreviewProvider {
    static var previews: some View {
        WaterBackground(percentage: 0.6)
    }
}

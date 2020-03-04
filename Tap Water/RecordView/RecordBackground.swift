//
//  RecordBackground.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/26.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct RecordBackground: View {
    var percentage: Double
    
    let startColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    let endColor = Color.init(red: 244/255, green: 245/255, blue: 255/255)
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height * CGFloat(self.percentage * 1.1)
                let waveCount = 100
                let waveHeight = (self.percentage == 0 ? 0 : 10)
                path.move(to: .init(x: 0, y: height))
                path.addLine(to: .init(x: 0, y: waveHeight))
                (1...waveCount).forEach { i in
                    let x = Double(i) / Double(waveCount) * Double(width)
                    let y = sin(Double(i) * 0.1) * Double(waveHeight) + Double(waveHeight)
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
            .position(x: geometry.size.width/2, y: geometry.size.height*(1.5-CGFloat(self.percentage * 1.1)))
            .transition(.move(edge: .bottom))
            .animation(.easeInOut(duration: 0.5))
        }
    }
}

struct RecordBackground_Previews: PreviewProvider {
    static var previews: some View {
        RecordBackground(percentage: 0.6)
    }
}

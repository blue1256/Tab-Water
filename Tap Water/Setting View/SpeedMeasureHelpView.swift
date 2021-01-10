//
//  SpeedMeasureHelpView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/09/02.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct SpeedMeasureHelpView: View {
    @ObservedObject var speedMeasureViewModel: SpeedMeasureViewModel
    
    @GestureState private var scrollOffset: CGFloat = 0
    @State private var scrollPosition: CGFloat = 0
    
    struct CupInfo : Identifiable {
        var id: String
        
        var image: String
        var type: String
        var volume: String
        
        init(_ cupImage: String, _ cupType: String, _ cupVolume: String) {
            self.image = cupImage
            self.type = cupType
            self.volume = cupVolume
            self.id = cupType
        }
    }
    
    let cupsInfo: [CupInfo] = [
        CupInfo("paperbag-cup", "PaperBagCup".localized, "PaperBagCupVolume".localized),
        CupInfo("soju-cup", "SojuGlass".localized, "SojuGlassVolume".localized),
        CupInfo("paper-cup", "PaperCup".localized, "PaperCupVolume".localized),
        CupInfo("home-cup", "TallTeaCup".localized, "TallTeaCupVolume".localized),
        CupInfo("glass-cup", "BeerGlass".localized, "BeerGlassVolume".localized)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text("HelpDetail".localized)
                    .font(.system(size: 15))
                    .padding()
                
                Text("CupSelector".localized)
                    .font(.headline)
                    .padding([.leading, .trailing])
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(cupsInfo) { cup in
                            Button(action: {
                                self.speedMeasureViewModel.fieldInput = cup.volume
                                self.speedMeasureViewModel.showPopover = false
                            }) {
                                VStack {
                                    Spacer()
                                    Image(cup.image)
                                    Spacer()
                                    Text("\(cup.type)\n\(cup.volume)ml")
                                        .multilineTextAlignment(.center)
                                        .padding(.bottom)
                                        .font(.system(size: 13))
                                        .foregroundColor(.black)
                                }
                                .frame(width: 150, height: 200)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 3)
                                )
                            }
                            .padding(8)
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
            .padding(.bottom)
        }
    }
}

struct SpeedMeasureHelpView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedMeasureHelpView(speedMeasureViewModel: SpeedMeasureViewModel())
    }
}

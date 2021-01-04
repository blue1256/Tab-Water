//
//  SpeedMeasureView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/25.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI


private extension SpeedMeasureView {
    var waterColor: Color {
        Color.init(red: 125/255, green: 175/255, blue: 235/255)
    }
    
    var animation: Animation {
        return Animation.easeInOut(duration: 2).repeatForever()
    }
    
    var inputField: some View {
        VStack {
            HStack {
                TextField("마실 양(ml)", text: self.$speedMeasureViewModel.fieldInput)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .frame(width: 200)
                    .font(.custom("", size: 30))
                    .disabled(self.speedMeasureViewModel.measuredCups > 0)
                
                Button(action: {
                    self.speedMeasureViewModel.showPopover = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                        .frame(width: 30, height: 30)
                }
            }
            
            Divider().frame(width: 250)
        }
    }
    
    var cupButtonView: some View {
        HStack {
            Button(action: {
                withAnimation {
                    self.speedMeasureViewModel.measuring = true
                    UIApplication.shared.endEditing()
                }
            }) {
                Image(self.speedMeasureViewModel.measuredCups >= 1 ? "cup-filled" : "cup-unfilled")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 80)
            }
            .disabled(self.speedMeasureViewModel.fieldInput.isEmpty || self.speedMeasureViewModel.measuredCups != 0)
            .padding(.leading, 30)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    self.speedMeasureViewModel.measuring = true
                }
            }) {
                Image(self.speedMeasureViewModel.measuredCups >= 2 ? "cup-filled" : "cup-unfilled")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 80)
            }
            .disabled(self.speedMeasureViewModel.fieldInput.isEmpty || self.speedMeasureViewModel.measuredCups != 1)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    self.speedMeasureViewModel.measuring = true
                }
            }) {
                Image(self.speedMeasureViewModel.measuredCups >= 3 ? "cup-filled" : "cup-unfilled")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 80)
            }
            .disabled(self.speedMeasureViewModel.fieldInput.isEmpty || self.speedMeasureViewModel.measuredCups != 2)
            .padding(.trailing, 30)
        }
        .transition(.opacity)
    }
    
    var waitingView: some View {
        ZStack {
            self.waterColor
                .clipShape(Circle())
                .frame(
                    width: 240,
                    height: 240
            )
                .blur(radius: 60)
                .scaleEffect((self.isAnimating ? 0.45 : 1))
                .animation(self.animation)
                .onAppear{
                    self.isAnimating.toggle()
            }
            Text("물을 마시세요!")
                .font(.custom("", size: 25))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity)
    }
    
    var speedIndicatorText: some View {
        Text("초당 \(Utils.shared.floorDouble(num: self.speedMeasureViewModel.speed))ml")
            .font(.custom("", size: 20))
    }
    
    var stopMeasureButton: some View {
        Button(action: {
            withAnimation {
                self.speedMeasureViewModel.measuring = false
            }
        }) {
            Text("완료")
                .font(.custom("", size: 20))
                .foregroundColor(self.waterColor)
        }
    }
    
    var measureCompleteButton: some View {
        Button(action: {
            withAnimation {
                self.speedMeasureViewModel.saveSpeed = true
                if let settingViewModel = self.settingViewModel {
                    settingViewModel.showSpeedMeasure = false
                } else {
                    self.viewControllerHolder?.present(style: .fullScreen) {
                        ContentView()
                    }
                }
            }
        }) {
            Image(systemName: "checkmark")
                .foregroundColor(self.waterColor)
            Text("측정 완료")
                .font(.custom("", size: 20))
                .foregroundColor(self.waterColor)
        }
    }
    
    var guideText: some View {
        Text("마실 양을 입력 후 빈 컵을 누르는 동시에\n물을 마시며 속도 측정을 시작해주세요")
            .foregroundColor(.init(white: 117/256))
            .multilineTextAlignment(.center)
    }
    
    var resetButton: some View {
        Button(action: {
            self.speedMeasureViewModel.reset = true
        }) {
            HStack{
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(self.waterColor)
                Text("다시 측정")
                    .font(.custom("", size: 20))
                    .foregroundColor(self.waterColor)
                    .padding(.top, 5)
            }
        }
    }
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Image(systemName: "arrow.left.circle")
                    .font(.system(size: 22))
                Text("목표 설정")
            }
        }).foregroundColor(self.waterColor)
    }
}

struct SpeedMeasureView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode
    @State var isAnimating = false
    var settingViewModel: SettingViewModel? = nil
    @ObservedObject var speedMeasureViewModel = SpeedMeasureViewModel()
    
    var bodyWithSafeArea: some View {
        VStack(alignment: .center) {
            inputField.padding(.top, 30)
            
            Spacer()
            
            if !self.speedMeasureViewModel.measuring {
                cupButtonView
            } else {
                waitingView
            }
            
            Spacer()
            
            if !self.speedMeasureViewModel.measuring && self.speedMeasureViewModel.speed != 0  {
                speedIndicatorText.padding(.bottom, 20)
            }
            
            if self.speedMeasureViewModel.measuring {
                stopMeasureButton.padding(.bottom, 10)
            } else if self.speedMeasureViewModel.measuredCups == 3 {
                measureCompleteButton.padding(.bottom, 10)
            } else {
                guideText.padding(.bottom, 10)
            }
            
            resetButton.padding(.bottom, 30)
        }
        .background(Color.white.onTapGesture {
            UIApplication.shared.endEditing()
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                backButton
        )
        .sheet(isPresented: self.$speedMeasureViewModel.showPopover) {
            SpeedMeasureHelpView()
        }
        .gesture(DragGesture()
                    .onChanged {gesture in
                        if gesture.startLocation.x < 100 && gesture.location.x > 100 {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
        )
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            bodyWithSafeArea
                .ignoresSafeArea(.keyboard, edges: .bottom)
        } else {
            bodyWithSafeArea
        }
    }
}

struct SpeedMeasureView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedMeasureView(settingViewModel: SettingViewModel())
    }
}

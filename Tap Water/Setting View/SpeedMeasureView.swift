//
//  SpeedMeasureView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/25.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI


private extension SpeedMeasureView {
    var animation: Animation {
        return Animation.easeInOut(duration: 2).repeatForever()
    }
    
    var inputField: some View {
        ZStack(alignment: .bottom) {
            Button(action: {
                self.speedMeasureViewModel.showPopover = true
            }) {
                Color.clear
            }
            .frame(width: 250, height: 30)
            .disabled(self.speedMeasureViewModel.manualInput)
            
            TextFieldView("VolumeToDrink".localized, text: self.$speedMeasureViewModel.fieldInput, showKeyboard: self.$speedMeasureViewModel.showKeyboard)
                .viewKeyboardType(.numberPad)
                .viewFont(UIFont.systemFont(ofSize: 24))
                .viewTextAlignment(.center)
                .frame(width: 250, height: 30)
                .disabled(!self.speedMeasureViewModel.manualInput)
                .padding(.bottom, 4)
            
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
            .scaleEffect(speedMeasureViewModel.measuredCups==0 ? 1.15 : 1)
            
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
            .scaleEffect(speedMeasureViewModel.measuredCups==1 ? 1.15 : 1)
            
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
            .scaleEffect(speedMeasureViewModel.measuredCups==2 ? 1.15 : 1)
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
            Text("DrinkWater".localized)
                .font(.custom("", size: 25))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity)
    }
    
    var speedIndicatorText: some View {
        Text("SpeedFormat".localized(self.speedMeasureViewModel.speed))
            .font(.custom("", size: 24))
    }
    
    var stopMeasureButton: some View {
        Button(action: {
            withAnimation {
                self.speedMeasureViewModel.measuring = false
            }
        }) {
            Text("Done".localized)
                .font(.custom("", size: 22))
                .foregroundColor(self.waterColor)
        }
    }
    
    var measureCompleteButton: some View {
        Button(action: {
            withAnimation {
                self.speedMeasureViewModel.saveSpeed = true
                if let settingViewModel = self.settingViewModel {
                    settingViewModel.showSpeedMeasure = false
                    settingViewModel.speed = speedMeasureViewModel.speed
                } else {
                    self.viewControllerHolder?.present(style: .fullScreen) {
                        ContentView()
                    }
                }
            }
        }) {
            Image(systemName: "checkmark")
                .foregroundColor(self.waterColor)
            Text("MeasuringComplete".localized)
                .font(.custom("", size: 22))
                .foregroundColor(self.waterColor)
        }
    }
    
    var resetButton: some View {
        Button(action: {
            withAnimation(.spring(dampingFraction: 0.75)) {
                self.speedMeasureViewModel.reset = true
            }
        }) {
            HStack{
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(self.waterColor)
                Text("MeasureAgain".localized)
                    .font(.custom("", size: 22))
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
                Text("Goal".localized)
            }
        }).foregroundColor(self.waterColor)
    }
    
    var guideView: some View {
        VStack(alignment: .leading) {
            Text("SpeedMeasureGuide".localized)
                .padding([.leading, .trailing], 16)
            
            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(dampingFraction: 0.75)) {
                        self.speedMeasureViewModel.showGuide = false
                    }
                }, label: {
                    HStack {
                        Text("Next".localized)
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 22))
                    .foregroundColor(waterColor)
                })
                .padding([.bottom, .trailing])
            }
        }
    }
    
    var volumeInputView: some View {
        VStack {
            HStack {
                Text("VolumeGuide".localized)
                    .padding([.leading, .trailing], 16)
                Spacer()
            }
            Spacer()
            inputField
            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(dampingFraction: 0.75)) {
                        self.speedMeasureViewModel.gotVolume = true
                    }
                }, label: {
                    HStack {
                        Text("SetVolume".localized)
                            .font(.custom("", size: 22))
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(speedMeasureViewModel.fieldInput == "" ? .gray : waterColor)
                })
                .padding([.bottom, .trailing])
                .disabled(self.speedMeasureViewModel.fieldInput == "")
            }
        }
    }
    
    var cupTouchView: some View {
        VStack {
            HStack {
                Text("MeasureGuideText".localized)
                    .padding([.leading, .trailing], 16)
                Spacer()
            }
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
            }
            
            resetButton.padding(.bottom, 32)
        }
    }
}

struct SpeedMeasureView: View {
    private let waterColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode
    @State var isAnimating = false
    var settingViewModel: SettingViewModel? = nil
    var onNavigation: Bool = false
    @ObservedObject var speedMeasureViewModel = SpeedMeasureViewModel()
    
    var bodyWithSafeArea: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack {
                    Text("SpeedMeasure".localized)
                        .font(.system(size: 30, weight: .bold))
                        .padding(.leading, 16)
                    Spacer()
                }
                .padding([.top, .bottom], 16)
                
                if speedMeasureViewModel.showGuide {
                    guideView
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                } else if speedMeasureViewModel.gotVolume {
                    cupTouchView
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    volumeInputView
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .sheet(isPresented: self.$speedMeasureViewModel.showPopover, title: "CupVolume".localized, height: 380)  {
                SpeedMeasureHelpView(speedMeasureViewModel: self.speedMeasureViewModel)
            }
            .background(Color.white.onTapGesture {
                UIApplication.shared.endEditing()
                speedMeasureViewModel.manualInput = false
            })
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
        }
        
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
        SpeedMeasureView(settingViewModel: SettingViewModel(), onNavigation: true)
    }
}

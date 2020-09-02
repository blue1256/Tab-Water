//
//  SpeedMeasureView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/25.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)

    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

extension UIViewController {
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, @ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        self.present(toPresent, animated: true, completion: nil)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SpeedMeasureView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode
    @State var isAnimating = false
    var settingViewModel: SettingViewModel? = nil
    @ObservedObject var speedMeasureViewModel = SpeedMeasureViewModel()
    
    var animation: Animation {
        return Animation.easeInOut(duration: 2).repeatForever()
    }
    
    let waterColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    
    var body: some View {
        GeometryReader { geometry in
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
                .padding(.top, 30)
                
                
                Divider()
                    .frame(width: 250)
                
                Spacer()
                
                if !self.speedMeasureViewModel.measuring {
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
                                .frame(width: geometry.size.width/5)
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
                                .frame(width: geometry.size.width/5)
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
                                .frame(width: geometry.size.width/5)
                        }
                        .disabled(self.speedMeasureViewModel.fieldInput.isEmpty || self.speedMeasureViewModel.measuredCups != 2)
                        .padding(.trailing, 30)
                    }
                    .transition(.opacity)
                } else {
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
                        Text("측정 중...")
                            .font(.custom("", size: 25))
                            .foregroundColor(.white)
                    }
                    .transition(.opacity)
                }

                Spacer()
                
                if !self.speedMeasureViewModel.measuring && self.speedMeasureViewModel.speed != 0  {
                    Text("초당 \(Utils.shared.floorDouble(num: self.speedMeasureViewModel.speed))mL")
                        .padding(.bottom, 20)
                        .font(.custom("", size: 20))
                }
                
                if self.speedMeasureViewModel.measuring {
                    Button(action: {
                        withAnimation {
                            self.speedMeasureViewModel.measuring = false
                        }
                    }) {
                        Text("완료")
                            .font(.custom("", size: 20))
                            .frame(width: geometry.size.width/3)
                            .foregroundColor(self.waterColor)
                    }
                    .padding(.bottom, 10)
                } else if self.speedMeasureViewModel.measuredCups == 3 {
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
                    .padding(.bottom, 10)
                } else {
                    Text("마실 양을 입력 후 빈 컵을 누르는 동시에\n물을 마시며 속도 측정을 시작해주세요")
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.center)
                }
                
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
                .padding(.bottom, 30)
            }
            .background(Color.white.onTapGesture {
                UIApplication.shared.endEditing()
            })
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack {
                        Image(systemName: "arrow.left.circle")
                            .font(.system(size: 22))
                        Text("목표 설정")
                    }
                }).foregroundColor(self.waterColor)
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
    }
}

struct SpeedMeasureView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedMeasureView(settingViewModel: SettingViewModel())
    }
}

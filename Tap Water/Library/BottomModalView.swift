//
//  BottomModalView.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/06.
//  Copyright © 2021 박종석. All rights reserved.
//

import SwiftUI

struct BottomModalView<Content: View>: View {
    @Binding var isPresented: Bool
    @GestureState private var translation: CGFloat = 0
    let height: CGFloat
    let content: Content
    let title: String
    
    init(isPresented: Binding<Bool>, title: String, height: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.height = height
        self.title = title
        self.content = content()
        self._isPresented = isPresented
    }
    
    var topBanner: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.title)
            
            Spacer()
            
            Button(action: {
                self.isPresented = false
            }, label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .padding(8)
                    .foregroundColor(.gray)
                    .background(Color.init(white: 232/255))
                    .clipShape(Circle())
            })
        }
        .padding()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                topBanner
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .frame(width: geometry.size.width, height: self.height + geometry.safeAreaInsets.bottom + 30)
            .position(x: geometry.size.width/2, y: geometry.size.height - self.height/2 + geometry.safeAreaInsets.bottom)
            .offset(y: max(self.translation, -5))
            .animation(.interactiveSpring())
            .shadow(radius: 10)
            .simultaneousGesture(
                DragGesture().updating($translation) { (value, state, transaction) in
                    state = value.translation.height
                }
                .onEnded { value in
                    let snapDistance = self.height * 0.5
                    guard value.translation.height > 0, value.predictedEndTranslation.height > snapDistance else {
                        return
                    }
                    self.isPresented = value.translation.height < 0
                }
            )
        }
    }
}

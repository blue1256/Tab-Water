//
//  TextFieldView.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/12.
//  Copyright © 2021 박종석. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct TextFieldView: UIViewRepresentable {
    typealias UIViewType = UITextField
    let textField = UITextField()
    
    var title: String
    @Binding var value: String
    @Binding var becomeFirstResponder: Bool
    
    init(_ title: String, text: Binding<String>, showKeyboard: Binding<Bool>) {
        self.title = title
        self._value = text
        self._becomeFirstResponder = showKeyboard
    }
    
    func makeUIView(context: Context) -> UITextField {
        textField.delegate = context.coordinator
        textField.placeholder = title
        return textField
    }
    
    func updateUIView(_ textField: UITextField, context: Context) {
        if self.becomeFirstResponder {
            print("show!")
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
                self.becomeFirstResponder = false
            }
        }
        textField.text = value
    }
    
    func viewKeyboardType(_ type: UIKeyboardType) -> TextFieldView {
        textField.keyboardAppearance = .light
        textField.keyboardType = type
        return self
    }
    
    func viewFont(_ font: UIFont) -> TextFieldView {
        textField.font = font
        return self
    }
    
    func viewTextAlignment(_ alignment: NSTextAlignment) -> TextFieldView {
        textField.textAlignment = alignment
        return self
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextFieldView
        
        init(parent: TextFieldView) {
            self.parent = parent
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.value = textField.text ?? ""
        }
    }
}

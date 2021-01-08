//
//  Extension.swift
//  Tap Water
//
//  Created by 박종석 on 2020/09/20.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import SwiftUI

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

public extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

public extension UIViewController {
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

public extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

public extension String {
    var localized: String {
        NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
    
    func localized(_ arguments: CVarArg) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String.localizedStringWithFormat(format, arguments)
    }
}

public extension View {
    func sheet<Content: View>(isPresented: Binding<Bool>, title: String = "", height: CGFloat, @ViewBuilder content: @escaping () -> Content) -> some View {
        return ZStack {
            self
                .zIndex(0)
            if isPresented.wrappedValue {
                BottomModalView(isPresented: isPresented, title: title, height: height, content: content)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

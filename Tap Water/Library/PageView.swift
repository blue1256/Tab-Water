//
//  PageView.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/10.
//  Copyright © 2021 박종석. All rights reserved.
//

import SwiftUI

struct PageView<Content: View>: View {
    var viewControllers: [UIHostingController<Content>]
    @Binding var currentPage: Int
    init(currentPage: Binding<Int>, _ views: [Content]) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
        self._currentPage = currentPage
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
            PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
        }
    }
}

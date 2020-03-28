//
//  contentViewModel.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/25.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    let appState = AppState.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var selectedTab: Int = 1
    
    @Published var selectedSettingView = SettingView()
    
    init() {
        appState.$selectedTab
            .sink { [weak self] tab in
                self?.selectedTab = tab
            }
            .store(in: &cancellables)
    }
}

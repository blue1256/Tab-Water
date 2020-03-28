//
//  AppState.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/21.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation

final class AppState: ObservableObject {
    static let shared = AppState()
    let userDefault = UserDefaults.standard
    
    @Published var showUserSetting: Bool = false
    
    @Published var selectedTab: Int = 1
    
    private init() {
    }
}

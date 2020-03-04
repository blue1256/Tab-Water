//
//  Profile.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/26.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation

final class UserProfile: ObservableObject {
    static let shared = UserProfile()
    
    private init() {}
    
    @Published var drankToday: Double = 0.0
    @Published var dailyGoal: Double = 2.0
    @Published var speed: Double = 50
}

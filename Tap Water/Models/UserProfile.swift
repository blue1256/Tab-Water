//
//  Profile.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/26.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import Combine

final class UserProfile: ObservableObject {
    static let shared = UserProfile()
    let userDefault = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    @Published var drankToday: Double
    @Published var dailyGoal: Double
    @Published var speed: Double
    
    private init() {
        drankToday = userDefault.double(forKey: "drankToday")
        dailyGoal = userDefault.double(forKey: "dailyGoal")
        speed = userDefault.double(forKey: "speed")
        
        self.$dailyGoal
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] goal in
                self?.userDefault.set(goal, forKey: "dailyGoal")
            }
            .store(in: &cancellables)
        
        self.$speed
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] speed in
                self?.userDefault.set(speed, forKey: "speed")
            }
            .store(in: &cancellables)
    }
}

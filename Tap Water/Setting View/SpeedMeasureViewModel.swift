//
//  SpeedMeasureViewModel.swift
//  Tap Water
//
//  Created by 박종석 on 2020/05/03.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import Combine

class SpeedMeasureViewModel: ObservableObject {
    private var userProfile = UserProfile.shared
    private var appState = AppState.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var fieldInput: String = ""
    @Published var saveSpeed: Bool = false
    @Published var reset: Bool = false
    @Published var measuring: Bool = false
    @Published var measuredCups: Int = 0
    @Published var speed: Double = 0
    @Published var startTime: Date? = nil
    @Published var showPopover: Bool = false
    
    init(){
        self.$saveSpeed
            .filter{ $0 }
            .sink { [weak self] _ in
                if let speed = self?.speed, speed != 0 {
                    UserDefaults.standard.set(speed, forKey: "speed")
                } else {
                    UserDefaults.standard.set(20, forKey: "speed")
                }
            }
            .store(in: &cancellables)
        
        self.$reset
            .filter { $0 }
            .sink { [weak self] _ in
                self?.fieldInput = ""
                self?.saveSpeed = false
                self?.measuring = false
                self?.measuredCups = 0
                self?.reset = false
                self?.speed = 0.0
            }
            .store(in: &cancellables)
        
        self.$measuring
            .removeDuplicates()
            .filter { $0 }
            .sink{ [weak self] _ in
                self?.startTime = Date()
            }
            .store(in: &cancellables)
        
        self.$measuring
            .removeDuplicates()
            .filter{ !$0 }
            .dropFirst()
            .sink{ [weak self] _ in
                var elapsed = 1.0
                if let startTime = self?.startTime {
                    elapsed = Double(-startTime.timeIntervalSinceNow)
                }
                if let speed = self?.speed, let measuredCups = self?.measuredCups, let input = self?.fieldInput, let drank = Double(input) {
                    let measuredCupsInDouble = Double(measuredCups)
                    let sum = speed * measuredCupsInDouble + (drank/elapsed)
                    self?.speed = sum / (measuredCupsInDouble + 1)
                }
                self?.measuredCups += 1
            }
            .store(in: &cancellables)
    }
}

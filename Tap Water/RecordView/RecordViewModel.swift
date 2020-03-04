//
//  RecordViewModel.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/27.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import Combine

class RecordViewModel: ObservableObject {
    var userProfile: UserProfile = UserProfile.shared
    private let timerPublisher = Timer.TimerPublisher(interval: 0.3, runLoop: .main, mode: .default)
    private var cancellables = Set<AnyCancellable>()
    
    var drankToday: Double = 0.0
    var dailyGoal: Double = 0.0
   
    @Published var percentage: Double = 0.0
    
    var start: Date? = nil
    
    @Published var isDrinking: Bool = false
    @Published var showCompleted: Bool = false
    
    init(){
        timerPublisher.connect().store(in: &cancellables)
        drankToday = userProfile.drankToday
        dailyGoal = userProfile.dailyGoal
        percentage = drankToday / dailyGoal
        
        userProfile.$drankToday
            .removeDuplicates()
            .sink(receiveValue: { [weak self] drank in
                self!.drankToday = drank
                self!.percentage = drank / self!.userProfile.dailyGoal
            })
            .store(in: &cancellables)
        
        self.$isDrinking
            .combineLatest(timerPublisher)
            .map { return $0.0 }
            .filter{ $0 }
            .sink(receiveValue: { [weak self] _ in
                self!.userProfile.drankToday += 0.3 * self!.userProfile.speed / 1000
            })
            .store(in: &cancellables)
        
        self.$percentage
            .filter{ $0 >= 1 }
            .first()
            .map { _ in return true }
            .assign(to: \.showCompleted, on: self)
            .store(in: &cancellables)
    }
}

//
//  StartViewModel.swift
//  Tap Water
//
//  Created by 박종석 on 2020/06/07.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import Combine

class StartViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var goalPickerValue: Int = 0
    @Published var saveGoal: Bool = false
    
    init() {
        self.$saveGoal
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                UserDefaults.standard.set(Double(self.goalPickerValue) / 10.0, forKey: "dailyGoal")
            }
            .store(in: &cancellables)
    }
}

//
//  Utils.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/27.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation

final class Utils {
    static let shared = Utils()
    
    private init() {}
    
    var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.roundingMode = .floor
        nf.maximumFractionDigits = 3
        nf.minimumFractionDigits = 1
        return nf
    }
    
    func floorDouble(num: Double) -> String {
        return self.numberFormatter.string(from: NSNumber(value: num))!
    }
    
    static func saveDefault(value: Any, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
}

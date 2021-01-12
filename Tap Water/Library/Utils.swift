//
//  Utils.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/27.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import SwiftUI

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
    
    func convertTimeFormat(time: Int) -> String {
        var time = time
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        
        formatter.dateFormat = "HH"
        if time == 24 { time = 0 }
        let d = formatter.date(from: "\(time)")
        
        formatter.dateFormat = "TimeFormat".localized
        return formatter.string(from: d ?? Date())
    }
    
    static func saveDefault(value: Any, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
}

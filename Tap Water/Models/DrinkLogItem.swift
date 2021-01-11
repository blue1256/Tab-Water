//
//  DrinkLogItem.swift
//  Tap Water
//
//  Created by 박종석 on 2021/01/11.
//  Copyright © 2021 박종석. All rights reserved.
//

import Foundation
import RealmSwift

class DrinkLogItem: Object, NSCopying, Codable, Identifiable {
    convenience init(time: String, volume: Double) {
        self.init()
        self.time = time
        self.volume = volume
        self.id = time
    }
    @objc dynamic var id: String = "0"
    @objc dynamic var time: String = "00:00:00"
    @objc dynamic var volume: Double = 0
    
    func copy(with zone: NSZone? = nil) -> Any {
        return DrinkLogItem(time: time, volume: volume)
    }
}

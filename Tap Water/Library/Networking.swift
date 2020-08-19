//
//  Networking.swift
//  Tap Water
//
//  Created by 박종석 on 2020/04/05.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import UIKit
import Firebase

final class Networking {
    static let shared: Networking = Networking()
    let db = Firestore.firestore()
    let deviceId = UIDevice.current.identifierForVendor!.uuidString
    
    private init() {}
    
    func getTodayRecord(_ callback: @escaping (DayRecord?)->Void) {
        let today = AppState.shared.today
        
        var record: DayRecord? = nil
        
        let docRef = db.collection(deviceId).document(today)
        
        docRef.getDocument { (document, err) in
            if let document = document, document.exists {
                record = try! JSONDecoder().decode(DayRecord.self, from: JSONSerialization.data(withJSONObject: document.data() ?? []))
            }
            callback(record)
        }
    }
    
    func setTodayRecord(_ record: DayRecord) -> Void {
        let data = try! JSONEncoder().encode(record)
        let dictionary = try! JSONSerialization.jsonObject(with: data) as! [String : Any]
        db.collection(deviceId).document(record.date).setData(dictionary)
    }
}

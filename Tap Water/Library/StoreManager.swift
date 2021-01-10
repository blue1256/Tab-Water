//
//  StoreManager.swift
//  Tap Water
//
//  Created by 박종석 on 2020/08/19.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import RealmSwift

class StoreManager {
    static let shared: StoreManager = StoreManager()
    
    var realm: Realm
    
    private init(){
        let config = Realm.Configuration(schemaVersion: 1) { (migration, oldSchemaVersion) in
            migration.enumerateObjects(ofType: DayRecord.className()) { (oldObject, newObject) in
                if oldSchemaVersion < 1 {
                }
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
        
        self.realm = try! Realm()
    }
    
    enum DateType {
        case last
        case first
    }
    
    func getTodayRecord() -> DayRecord? {
        return realm.objects(DayRecord.self).filter("date == %@", AppState.shared.today).first?.copy() as? DayRecord
    }
    
    func setTodayRecord(_ record: DayRecord) {
        try! realm.write {
//            if let savedRecord = realm.objects(DayRecord.self).filter("date == %@", AppState.shared.today).first {
//            }
            let copy = record.copy() as! DayRecord
            realm.add(copy, update: .modified)
        }
    }
    
    func getRecordDate(_ type: DateType) -> String? {
        let firstRecord = realm.objects(DayRecord.self).sorted(byKeyPath: "date", ascending: type == .first).first
        return firstRecord?.date
    }
    
    func getMonthRecord(month: String) -> [DayRecord] {
        let monthRecords = realm.objects(DayRecord.self).filter("date LIKE '\(month+"*")'")
        return Array(monthRecords.map { $0.copy() as! DayRecord })
    }
    
    func getAllRecords() -> [DayRecord] {
        let records = realm.objects(DayRecord.self)
        return Array(records.map { $0.copy() as! DayRecord })
    }
    
    func deleteAll() {
        try! realm.write {
            let allRecords = realm.objects(DayRecord.self)
            realm.delete(allRecords)
            
            let userDefault = UserDefaults.standard
            userDefault.set("", forKey: "today")
            userDefault.set(0, forKey: "drankToday")
            userDefault.set(false, forKey: "completedToday")
        }
    }
}

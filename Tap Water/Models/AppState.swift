//
//  AppState.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/21.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import UserNotifications

final class AppState: ObservableObject {
    static let shared = AppState()
    let userDefault = UserDefaults.standard
    let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var showUserSetting: Bool = false
    
    @Published var selectedTab: Int = 1
    
    @Published var updateCalendar: Bool = false
    
    @Published var deleteCalendar: Bool = false
    
    var today: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }
    
    var version: String {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return version
    }
    
    var appStoreVersion: String {
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=1528884225"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let appStoreVersion = results[0]["version"] as? String
            else { return "" }
        return appStoreVersion
    }
    
    func isUpdateAvailable() -> Bool {
        if self.version == self.appStoreVersion && self.version != "" {
            return false
        } else {
            return true
        }
    }
    
    func requestNotification(){
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.notificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func sendNotification(){
        let content = UNMutableNotificationContent()
        content.title = "물 마시기"
        content.body = "오늘 목표량을 아직 다 못 마셨어요!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(UserProfile.shared.remindingTime * 3600), repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        if !UserProfile.shared.completedToday {
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }
}

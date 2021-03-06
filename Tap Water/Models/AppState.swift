//
//  AppState.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/21.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import UserNotifications
import Combine

final class AppState: ObservableObject {
    static let shared = AppState()
    let userDefault = UserDefaults.standard
    let notificationCenter = UNUserNotificationCenter.current()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showUserSetting: Bool = false
    
    @Published var selectedTab: Int = 1
    
    @Published var updateCalendar: Bool = false
    
    @Published var deleteCalendar: Bool = false
    
    @Published var completedToday: Bool = false
    @Published var enabledNotification: Bool = true
    @Published var remindingTime: Int = 1
    @Published var launchedBefore: Bool = true
    
    @Published var refreshRecord: Bool = false
    
    var version: String = ""
    
    var appStoreVersion: String = ""
    
    var today: String {
        let formatter = DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }
    
    private init() {
        getVersion()
        getAppStoreVersion()
        
        completedToday = userDefault.bool(forKey: "completedToday")
        enabledNotification = !userDefault.bool(forKey: "notification")
        remindingTime = userDefault.integer(forKey: "remindingTime") == 0 ? 1 : userDefault.integer(forKey: "remindingTime")
        launchedBefore = userDefault.bool(forKey: "launchedBefore")
        
        self.$completedToday
            .sink{ [weak self] comp in
                self?.userDefault.set(comp, forKey: "completedToday")
            }
            .store(in: &cancellables)
        
        self.$enabledNotification
            .sink{ [weak self] enabled in
                guard let self = self else { return }
                self.userDefault.set(!enabled, forKey: "notification")
            }
            .store(in: &cancellables)
        
        self.$remindingTime
            .sink { [weak self] time in
                guard let self = self else { return }
                self.userDefault.set(time, forKey: "remindingTime")
            }
            .store(in: &cancellables)
        
        self.$launchedBefore
            .sink { [weak self] launched in
                guard let self = self else { return }
                self.userDefault.set(launched, forKey: "launchedBefore")
            }
            .store(in: &cancellables)
    }
    
    func getVersion() {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String else {
            return
        }
        self.version = version
    }
    
    func getAppStoreVersion() {
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=1528884225"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let appStoreVersion = results[0]["version"] as? String
            else { return }
        self.appStoreVersion = appStoreVersion
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
        content.title = "DrinkWaterNotiTitle".localized
        content.body = "DrinkWaterNotiContent".localized
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(remindingTime * 3600), repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        if !completedToday {
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }
}

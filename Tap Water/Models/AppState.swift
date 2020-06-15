//
//  AppState.swift
//  Tap Water
//
//  Created by 박종석 on 2020/03/21.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation

final class AppState: ObservableObject {
    static let shared = AppState()
    let userDefault = UserDefaults.standard
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
        guard let url = URL(string: "http://itunes.apple.com/lookup?bundleId=com.jongseokpark.Tap-Water"),
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
    
    @Published var showUserSetting: Bool = false
    
    @Published var selectedTab: Int = 1
    
    @Published var updateCalendar: Bool = false
}

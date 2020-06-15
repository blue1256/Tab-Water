//
//  SummaryViewModel.swift
//  Tap Water
//
//  Created by 박종석 on 2020/06/07.
//  Copyright © 2020 박종석. All rights reserved.
//

import Foundation
import JTAppleCalendar
import Combine

class SummaryViewModel: ObservableObject {
    var userProfile: UserProfile = UserProfile.shared
    private var cancellables = Set<AnyCancellable>()
    
    var firstDate = "20200101"
    
    var searchedMonth = [String]()
    
    @Published var monthShowing: String
    @Published var records = [DayRecord]()
    @Published var selectedDate: Date
    @Published var selectedRecord: DayRecord? = nil
    @Published var selectedDateInString: String = ""
    @Published var calendar: JTACMonthView? = nil
    
    init() {
        selectedDate = Date()
        monthShowing = AppState.shared.today
        monthShowing.removeLast(2)
        
        Networking.shared.getFirstRecordDate { [weak self] (date) in
            self?.firstDate = date
        }
        
        self.$monthShowing
            .removeDuplicates()
            .sink { [weak self] month in
                Networking.shared.getMonthRecords(month: month) { [weak self] newRecords in
                    if !(self?.searchedMonth.contains(month) ?? true) {
                        self?.records.append(contentsOf: newRecords)
                        self?.calendar?.reloadData()
                        self?.searchedMonth.append(month)
                    }
                }
            }
            .store(in: &cancellables)
        
        self.$selectedDate
            .sink { [weak self] (date) in
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "yyyyMMdd"
                self?.selectedRecord = self?.records.first { $0.date == formatter.string(from: date) }
                
                formatter.dateFormat = "yyyy년\nM월 d일"
                self?.selectedDateInString = formatter.string(from: date)
            }
            .store(in: &cancellables)
        
        AppState.shared.$updateCalendar
            .filter { $0 }
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink{ [weak self] _ in
                Networking.shared.getTodayRecord { [weak self] record in
                    guard let self = self else {
                        return
                    }
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "ko_KR")
                    formatter.dateFormat = "yyyyMMdd"
                    
                    if let record = record {
                        if let target = self.records.firstIndex(where: { $0.date == AppState.shared.today }) {
                            self.records.remove(at: target)
                        }
                        self.records.append(record)
                        let strDate = formatter.string(from: self.selectedDate)
                        if strDate == AppState.shared.today {
                            self.selectedRecord = record
                        }
                    }
                }
                AppState.shared.updateCalendar = false
            }
            .store(in: &cancellables)
    }
}

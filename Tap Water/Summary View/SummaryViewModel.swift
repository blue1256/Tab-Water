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
    private let formatter = DateFormatter()
    private var cancellables = Set<AnyCancellable>()
    
    var firstDate = AppState.shared.today
    
    var searchedMonth = [String]()
    
    @Published var monthTitle: String = ""
    @Published var monthShowing: [String] = ["", ""]
    @Published var records = [DayRecord]()
    @Published var selectedDate: Date
    @Published var selectedRecord: DayRecord? = nil
    @Published var selectedDateInString: String = ""
    @Published var calendar: JTACMonthView? = nil
    @Published var showStats: Bool = false
    
    init() {
        formatter.timeZone = .autoupdatingCurrent
        selectedDate = Date()
        monthShowing[0] = AppState.shared.today
        monthShowing[0].removeLast(2)
        
        if let firstDate = StoreManager.shared.getRecordDate(.first) {
            self.firstDate = firstDate
        }
        
        self.$monthShowing
            .removeDuplicates()
            .sink { [weak self] months in
                guard let self = self else { return }
                months.forEach { month in
                    if !self.searchedMonth.contains(month) && month != "" {
                        let newRecords = StoreManager.shared.getMonthRecord(month: month)
                        self.records.append(contentsOf: newRecords)
                        self.searchedMonth.append(month)
                    }
                }
                self.calendar?.reloadData()
            }
            .store(in: &cancellables)
        
        self.$selectedDate
            .sink { [weak self] (date) in
                guard let self = self else { return }
                self.formatter.dateFormat = "yyyyMMdd"
                self.selectedRecord = self.records.first { $0.date == self.formatter.string(from: date) }
                
                self.formatter.dateFormat = "SelectionDateFormat".localized
                self.selectedDateInString = self.formatter.string(from: date)
            }
            .store(in: &cancellables)
        
        AppState.shared.$deleteCalendar
            .filter { $0 }
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink{ [weak self] _ in
                guard let self = self else { return }
                self.records.removeAll()
                AppState.shared.deleteCalendar = false
            }
            .store(in: &cancellables)
    }
    
    func refreshToday() {
        if let todayIndex = records.firstIndex(where: {  $0.date == AppState.shared.today }) {
            records.remove(at: todayIndex)
        }
        if let todayRecord = StoreManager.shared.getTodayRecord() {
            records.append(todayRecord)
            if selectedRecord?.date == todayRecord.date {
                selectedRecord = todayRecord
            }
        }
    }
}

//
//  SummaryView.swift
//  Tap Water
//
//  Created by 박종석 on 2020/02/24.
//  Copyright © 2020 박종석. All rights reserved.
//

import SwiftUI
import JTAppleCalendar

class CalendarDelegate: NSObject, JTACMonthViewDelegate, JTACMonthViewDataSource {
    let formatter = DateFormatter()
    @ObservedObject var summaryViewModel: SummaryViewModel
    
    init(_ summaryViewModel: SummaryViewModel){
        self.summaryViewModel = summaryViewModel
        formatter.timeZone = .autoupdatingCurrent
        
        super.init()
    }
    
    func setMonthTitle(_ visibleDates: DateSegmentInfo) {
        formatter.dateFormat = "yyyyMM"
        summaryViewModel.monthShowing[0] = formatter.string(from: visibleDates.monthDates[0].date)
        if visibleDates.indates.count > 0 {
            summaryViewModel.monthShowing[1] = formatter.string(from: visibleDates.indates[0].date)
        }
        
        formatter.dateFormat = "MonthFormat".localized
        
        let cal = Calendar(identifier: .gregorian)
        let rangeYear = cal.component(.year, from: visibleDates.monthDates[0].date)
        let todayYear = cal.component(.year, from: Date())
        if rangeYear == todayYear {
            formatter.dateFormat = "MonthFormatShortened".localized
        }
        
        summaryViewModel.monthTitle = formatter.string(from: visibleDates.monthDates[0].date)
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setMonthTitle(visibleDates)
    }

    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setMonthTitle(visibleDates)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: DateCell.reuseID, for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let cell = cell {
            let dateCell = cell as! DateCell
            configureCell(cell: dateCell, cellState: cellState)
            summaryViewModel.selectedDate = date
            if(cellState.dateBelongsTo != .thisMonth) {
                calendar.scrollToDate(cellState.date)
            }
        }
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let cell = cell {
            let dateCell = cell as! DateCell
            configureCell(cell: dateCell, cellState: cellState)
        }
    }
    
    func configureCell(cell: DateCell, cellState: CellState) {
        if cellState.isSelected {
            cell.background.layer.borderColor = UIColor.init(red: 125/255, green: 175/255, blue: 235/255, alpha: 1).cgColor
            UIView.animate(withDuration: 0.5) {
                cell.background.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                cell.dateLabel.font = .systemFont(ofSize: 22, weight: .semibold)
            }
        } else {
            cell.background.layer.borderColor = UIColor.clear.cgColor
            UIView.animate(withDuration: 0.5) {
                cell.background.transform = CGAffineTransform(scaleX: 5/6, y: 5/6)
                cell.dateLabel.font = .systemFont(ofSize: 18)
            }
            if cellState.dateBelongsTo == .thisMonth {
                cell.dateLabel.textColor = .black
            } else {
                cell.dateLabel.textColor = .gray
            }
        }
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! DateCell
        cell.dateLabel.text = cellState.text
        formatter.dateFormat = "yyyyMMdd"
        
        let percentage = summaryViewModel.records
            .first { $0.date == formatter.string(from: date) }
            .flatMap{ $0.drankToday / $0.dailyGoal } ?? 0
        
        cell.background.backgroundColor = UIColor.init(red: 125/255, green: 175/255, blue: 235/255, alpha: CGFloat(percentage))
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: DateHeader.reuseID, for: indexPath) as! DateHeader

        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 10)
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyyMMdd"
        let startDate = formatter.date(from: summaryViewModel.firstDate)!
        let endDate = Date()
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
}

class DateHeader: JTACMonthReusableView {
    static let reuseID = "dateHeader"

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var weekDay = [UILabel]()
        let dayName = ["Sun".localized,
                       "Mon".localized,
                       "Tue".localized,
                       "Wed".localized,
                       "Thu".localized,
                       "Fri".localized,
                       "Sat".localized]
        for i in 0..<7 {
            weekDay.append(UILabel())
            weekDay[i].text = dayName[i]
            weekDay[i].textColor = .darkGray
            weekDay[i].font = .boldSystemFont(ofSize: 12)
        }
        
        for i in 0..<7 {
            self.addSubview(weekDay[i])
            weekDay[i].textAlignment = .center
            weekDay[i].translatesAutoresizingMaskIntoConstraints = false
        }
        
        weekDay[0].leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        for i in 1..<7 {
            weekDay[i-1].trailingAnchor.constraint(equalTo: weekDay[i].leadingAnchor).isActive = true
            weekDay[i-1].widthAnchor.constraint(equalTo: weekDay[i].widthAnchor).isActive = true
        }
        
        weekDay[6].trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DateCell: JTACDayCell {
    static let reuseID = "dateCell"

    var background = UIView()
    var dateLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(self.background)
        contentView.addSubview(self.dateLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        background.layer.cornerRadius = 20
        background.layer.borderWidth = 1.5
        background.translatesAutoresizingMaskIntoConstraints = false
        
        background.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        background.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        background.heightAnchor.constraint(equalToConstant: 40).isActive = true
        background.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) has not been implemented")
    }
}

struct CalendarView: UIViewRepresentable {
    @ObservedObject var summaryViewModel: SummaryViewModel
    
    func makeCoordinator() -> CalendarDelegate {
        CalendarDelegate(self.summaryViewModel)
    }
    
    func makeUIView(context: UIViewRepresentableContext<CalendarView>) -> UIView {
        let calendar = JTACMonthView()
        calendar.backgroundColor = .white
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        
        calendar.register(DateCell.self, forCellWithReuseIdentifier: DateCell.reuseID)
        
        calendar.register(DateHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DateHeader.reuseID)
        
        calendar.calendarDelegate = context.coordinator
        calendar.calendarDataSource = context.coordinator
        calendar.scrollDirection = .horizontal
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.showsHorizontalScrollIndicator = false
        
        let selection = summaryViewModel.selectedDate
        
        calendar.scrollToDate(selection, animateScroll: false)
        calendar.selectDates([selection])
        
        context.coordinator.formatter.dateFormat = "MonthFormatShortened".localized
        summaryViewModel.monthTitle = context.coordinator.formatter.string(from: selection)
        
        summaryViewModel.calendar = calendar
        return calendar
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<CalendarView>) {}
}

private extension SummaryView {
    var upperBanner: some View {
        HStack {
            Text("\(self.summaryViewModel.monthTitle)")
                .font(.system(size: 30, weight: .semibold))
                .padding()
            Spacer()
            Button(action: {
                
            }, label: {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.gray)
            })
            .padding()
        }
    }
    
    var dayInfoSection: some View {
        GeometryReader { geometry in
            HStack {
                Text("\(self.summaryViewModel.selectedDateInString)")
                    .multilineTextAlignment(.leading)
                    .frame(width: geometry.size.width*0.25)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.trailing, -8)
                Divider()
                VStack(alignment: .leading) {
                    if let selectedRecord = self.summaryViewModel.selectedRecord, selectedRecord.drankToday != 0.0 {
                        let drankToday = selectedRecord.drankToday
                        let dailyGoal = selectedRecord.dailyGoal
                        
                        Text("\(Utils.shared.floorDouble(num: drankToday / dailyGoal * 100))%")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(waterColor)
                            .padding(.bottom, 1)
                        Text("\("Drank".localized): \(Utils.shared.floorDouble(num: drankToday))L")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        Text("\("Goal".localized): \(Utils.shared.floorDouble(num: dailyGoal))L")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    } else {
                        Text("NoRecord".localized)
                            .padding(.bottom, 2)
                        Text("NoRecordContent".localized)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
        }
    }
}

struct SummaryView: View {
    @ObservedObject var summaryViewModel = SummaryViewModel()
    
    let waterColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                upperBanner
                
                CalendarView(summaryViewModel: self.summaryViewModel)
                    .frame(height: geometry.size.height*0.65)
                
                Divider()
                
                dayInfoSection
                    .padding(.bottom, 10)
            }
        }
        .onAppear {
            summaryViewModel.refreshToday()
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

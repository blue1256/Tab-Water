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
    @ObservedObject var summaryViewModel: SummaryViewModel
    
    init(_ summaryViewModel: SummaryViewModel){
        self.summaryViewModel = summaryViewModel
        super.init()
    }
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyyMM"
        summaryViewModel.monthShowing[0] = formatter.string(from: visibleDates.monthDates[0].date)
        if visibleDates.indates.count > 0 {
            summaryViewModel.monthShowing[1] = formatter.string(from: visibleDates.indates[0].date)
        }
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
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyyMMdd"
        
        let percentage = summaryViewModel.records
            .first { $0.date == formatter.string(from: date) }
            .flatMap{ $0.drankToday / $0.dailyGoal } ?? 0
        
        cell.background.backgroundColor = UIColor.init(red: 125/255, green: 175/255, blue: 235/255, alpha: CGFloat(percentage))
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "YYYY년 M월"
        
        let cal = Calendar(identifier: .gregorian)
        let rangeYear = cal.component(.year, from: range.start)
        let todayYear = cal.component(.year, from: Date())
        if rangeYear == todayYear {
            formatter.dateFormat = "M월"
        }
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: DateHeader.reuseID, for: indexPath) as! DateHeader
        header.monthTitle.text = formatter.string(from: range.start)
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyyMMdd"
        let startDate = formatter.date(from: summaryViewModel.firstDate)!
        let endDate = Date()
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
}

class DateHeader: JTACMonthReusableView {
    static let reuseID = "dateHeader"

    var monthTitle: UILabel

    override init(frame: CGRect) {
        let monthSize = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        monthTitle = UILabel(frame: monthSize)
        
        var weekDay = [UILabel]()
        let dayName = ["일", "월", "화", "수", "목", "금", "토"]
        for i in 0..<7 {
            weekDay.append(UILabel())
            weekDay[i].text = dayName[i]
            weekDay[i].textColor = .gray
            weekDay[i].font = .systemFont(ofSize: 12)
        }
        
        super.init(frame: frame)
        self.addSubview(monthTitle)
        
        monthTitle.textAlignment = .center
        monthTitle.translatesAutoresizingMaskIntoConstraints = false
        monthTitle.font = .boldSystemFont(ofSize: 30)
        
        for i in 0..<7 {
            self.addSubview(weekDay[i])
            weekDay[i].textAlignment = .center
            weekDay[i].translatesAutoresizingMaskIntoConstraints = false
            monthTitle.bottomAnchor.constraint(equalTo: weekDay[i].topAnchor, constant: -10).isActive = true
        }
        
        weekDay[0].leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        for i in 1..<7 {
            weekDay[i-1].trailingAnchor.constraint(equalTo: weekDay[i].leadingAnchor).isActive = true
            weekDay[i-1].widthAnchor.constraint(equalTo: weekDay[i].widthAnchor).isActive = true
        }
        
        weekDay[6].trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        monthTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        monthTitle.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10).isActive = true
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
        
        summaryViewModel.calendar = calendar
        return calendar
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<CalendarView>) {}
}

private extension SummaryView {
    var dayInfoSection: some View {
        GeometryReader { geometry in
            HStack {
                Text("\(self.summaryViewModel.selectedDateInString)")
                    .frame(width: geometry.size.width*0.25)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                Divider()
                VStack(alignment: .leading) {
                    if self.summaryViewModel.selectedRecord != nil {
                        Text("마신 양: \(Utils.shared.floorDouble(num: self.summaryViewModel.selectedRecord!.drankToday))L")
                            .foregroundColor(.white)
                            .padding(.bottom, 2)
                        Text("목표치: \(Utils.shared.floorDouble(num: self.summaryViewModel.selectedRecord!.dailyGoal))L")
                            .foregroundColor(.white)
                    } else {
                        Text("정보가 없습니다.")
                            .foregroundColor(.white)
                            .padding(.bottom, 2)
                        Text("다른 날짜를 선택해주세요.")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .background(
                Color.init(red: 125/255, green: 175/255, blue: 235/255)
            )
        }
    }
}

struct SummaryView: View {
    @ObservedObject var summaryViewModel = SummaryViewModel()
    
    let waterColor = Color.init(red: 125/255, green: 175/255, blue: 235/255)
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                CalendarView(summaryViewModel: self.summaryViewModel)
                    .frame(height: geometry.size.height*0.75)
                    .padding(.top, 10)
                
                dayInfoSection
            }
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

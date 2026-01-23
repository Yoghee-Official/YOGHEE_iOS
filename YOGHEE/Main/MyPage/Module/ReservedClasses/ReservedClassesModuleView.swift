//
//  ReservedClassesModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct ReservedClassesModuleView: View {
    let classes: [YogaClassScheduleDTO]
    let onItemTap: (String) -> Void
    
    @State private var selectedDate: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }()
    
    // 기존 computed property 유지
    private var filteredClasses: [YogaClassScheduleDTO] {
        classes.filter { $0.day == selectedDate }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 달력 뷰
            CalendarView(
                reservedClasses: classes,
                selectedDate: $selectedDate
            )
            .padding(.horizontal, 16.ratio())
            
            // 선택된 날짜의 클래스 리스트
            VStack(spacing: 0) {
                ForEach(Array(filteredClasses.enumerated()), id: \.element.classId) { index, item in
                    YogaClassScheduleItemView(
                        item: item,
                        onTap: { onItemTap(item.classId) }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 16.ratio())
            .animation(.easeOut(duration: 0.4), value: filteredClasses.map { $0.classId })
        }
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    let reservedClasses: [YogaClassScheduleDTO]
    @Binding var selectedDate: String
    
    @State private var currentDate = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let weekDays = ["월", "화", "수", "목", "금", "토", "일"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더 (년도, 월, 화살표)
            CalendarHeaderView(
                currentDate: currentDate,
                onPreviousMonth: moveToPreviousMonth,
                onNextMonth: moveToNextMonth
            )
            .padding(.bottom, 12.ratio())
            
            // 구분선
            Rectangle()
                .fill(Color.white)
                .frame(height: 1)
            
            VStack(spacing: 16.ratio()) {
                // 요일 헤더
                WeekdayHeaderView()
                
                // 날짜 그리드
                CalendarGridView(
                    currentDate: currentDate,
                    reservedDates: getReservedDates(),
                    selectedDate: $selectedDate
                )
            }
            .padding(.top, 16.ratio())
        }
        .padding(.horizontal, 16.ratio())
        .padding(.vertical, 16.ratio())
        .frame(width: 343.ratio())
        .background(Color.FlowBlue)
        .cornerRadius(8.ratio())
    }
    
    private func moveToPreviousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate),
              isWithinOneYear(newDate) else { return }
        currentDate = newDate
    }
    
    private func moveToNextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate),
              isWithinOneYear(newDate) else { return }
        currentDate = newDate
    }
    
    private func isWithinOneYear(_ date: Date) -> Bool {
        let today = Date()
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today),
              let oneYearLater = calendar.date(byAdding: .year, value: 1, to: today) else {
            return false
        }
        return date >= oneYearAgo && date <= oneYearLater
    }
    
    private func getReservedDates() -> Set<String> {
        var dates = Set<String>()
        for classItem in reservedClasses {
            // day 필드가 "yyyy-MM-dd" 형식이므로 그대로 사용
            dates.insert(classItem.day)
        }
        return dates
    }
}

// MARK: - Calendar Header View
struct CalendarHeaderView: View {
    let currentDate: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        HStack {
            // 년도
            Text(String(calendar.component(.year, from: currentDate)))
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            
            Spacer()
            
            // 이전 달 화살표
            Button(action: onPreviousMonth) {
                Image("LeftArrowIcon")
                    .frame(width: 8.ratio(), height: 8.ratio())
            }
            
            // 월
            Text("\(calendar.component(.month, from: currentDate))월")
                .pretendardFont(.bold, size: 14)
                .foregroundColor(.DarkBlack)
                .frame(minWidth: 40)
            
            // 다음 달 화살표
            Button(action: onNextMonth) {
                Image("RightArrowIcon")
                    .frame(width: 8.ratio(), height: 8.ratio())
            }
        }
    }
}

// MARK: - Weekday Header View
struct WeekdayHeaderView: View {
    private let weekDays = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                Text(day)
                    .pretendardFont(.regular, size: 12.ratio())
                    .foregroundColor(.DarkBlack)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Calendar Grid View
struct CalendarGridView: View {
    let currentDate: Date
    let reservedDates: Set<String>
    @Binding var selectedDate: String
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        let days = generateCalendarDays()
        
        LazyVGrid(columns: columns, spacing: 8.ratio()) {
            ForEach(days, id: \.date) { day in
                CalendarDayCell(
                    day: day.day,
                    dateString: day.dateString,
                    isCurrentMonth: day.isCurrentMonth,
                    isReserved: day.isReserved,
                    isSelected: day.dateString == selectedDate,
                    onTap: {
                        if day.isCurrentMonth {
                            selectedDate = day.dateString
                        }
                    }
                )
            }
        }
    }
    
    private func generateCalendarDays() -> [CalendarDay] {
        var days: [CalendarDay] = []
        
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        
        guard let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart),
              let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart) else {
            return days
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let totalDaysInMonth = daysInMonth.count
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 이전 달의 날짜들 (빈 공간)
        for _ in 1..<firstWeekday {
            days.append(CalendarDay(day: 0, dateString: "", date: Date(), isCurrentMonth: false, isReserved: false))
        }
        
        // 현재 달의 날짜들
        for day in 1...totalDaysInMonth {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                let dateString = dateFormatter.string(from: date)
                let isReserved = reservedDates.contains(dateString)
                days.append(CalendarDay(day: day, dateString: dateString, date: date, isCurrentMonth: true, isReserved: isReserved))
            }
        }
        
        return days
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let day: Int
    let dateString: String
    let isCurrentMonth: Bool
    let isReserved: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if isReserved {
                    // 예약된 날짜 배경 (그라데이션)
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 214/255, green: 246/255, blue: 149/255), location: 0.4),
                            .init(color: Color(red: 241/255, green: 255/255, blue: 212/255), location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 14.ratio()
                    )
                    .frame(width: 28.ratio(), height: 28.ratio())
                    .clipShape(Circle())
                }
                
                // 선택된 날짜 테두리
                if isSelected {
                    Circle()
                        .stroke(Color.MindOrange, lineWidth: 2)
                        .frame(width: 28.ratio(), height: 28.ratio())
                }
                
                if isCurrentMonth {
                    Text("\(day)")
                        .pretendardFont(isReserved ? .bold : .medium, size: 12.ratio())
                        .foregroundColor(.DarkBlack)
                }
            }
            .frame(height: 28.ratio())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Calendar Day Model
struct CalendarDay {
    let day: Int
    let dateString: String
    let date: Date
    let isCurrentMonth: Bool
    let isReserved: Bool
}

#Preview {
    ReservedClassesModuleView(
        classes: [
            YogaClassScheduleDTO(
                classId: "1",
                className: "자연에서 즐기는 야외 요가",
                day: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: Date())
                }(),
                dayOfWeek: Calendar.current.component(.weekday, from: Date()),
                thumbnailUrl: "https://via.placeholder.com/48",
                address: "서울 관악구",
                attendance: 23,
                isPast: false,
                categories: []
            ),
            YogaClassScheduleDTO(
                classId: "2",
                className: "요가 수련 두 번째",
                day: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    guard let date = Calendar.current.date(byAdding: .day, value: 2, to: Date()) else {
                        return formatter.string(from: Date())
                    }
                    return formatter.string(from: date)
                }(),
                dayOfWeek: 3,
                thumbnailUrl: "https://via.placeholder.com/48",
                address: "서울 강남구",
                attendance: 15,
                isPast: false,
                categories: []
            )
        ],
        onItemTap: { _ in }
    )
}

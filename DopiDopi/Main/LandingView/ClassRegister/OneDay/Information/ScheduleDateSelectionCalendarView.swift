//
//  ScheduleDateSelectionCalendarView.swift
//  YOGHEE
//
//  Created by 0ofKim on 3/3/26.
//

import SwiftUI

// MARK: - Schedule Date Selection Calendar (다중 선택, #D6F695)
struct ScheduleDateSelectionCalendarView: View {
    @Binding var selectedDates: Set<String>
    @State private var currentDate = Date()
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarHeaderView(
                currentDate: currentDate,
                onPreviousMonth: moveToPreviousMonth,
                onNextMonth: moveToNextMonth
            )
            .padding(.bottom, 12.ratio())
            
            VStack(spacing: 16.ratio()) {
                WeekdayHeaderView()
                
                ScheduleCalendarGridView(
                    currentDate: currentDate,
                    selectedDates: $selectedDates
                )
            }
            .padding(.top, 16.ratio())
        }
        .padding(16.ratio())
        .frame(width: 343.ratio())
        .background(Color.Background)
        .cornerRadius(8.ratio())
    }
    
    private func moveToPreviousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate),
              isWithinTwelveMonths(newDate) else { return }
        currentDate = newDate
    }
    
    private func moveToNextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate),
              isWithinTwelveMonths(newDate) else { return }
        currentDate = newDate
    }
    
    private func isWithinTwelveMonths(_ date: Date) -> Bool {
        let today = Date()
        guard let start = calendar.date(byAdding: .month, value: -1, to: today),
              let end = calendar.date(byAdding: .month, value: 12, to: today) else {
            return false
        }
        return date >= start && date <= end
    }
}

// MARK: - Schedule Calendar Grid (다중 선택)
private struct ScheduleCalendarGridView: View {
    let currentDate: Date
    @Binding var selectedDates: Set<String>
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        let days = generateCalendarDays()
        
        LazyVGrid(columns: columns, spacing: 8.ratio()) {
            ForEach(days, id: \.date) { day in
                ScheduleCalendarDayCell(
                    day: day.day,
                    dateString: day.dateString,
                    isCurrentMonth: day.isCurrentMonth,
                    isSelected: selectedDates.contains(day.dateString),
                    onTap: {
                        if day.isCurrentMonth && !day.dateString.isEmpty {
                            if selectedDates.contains(day.dateString) {
                                selectedDates.remove(day.dateString)
                            } else {
                                selectedDates.insert(day.dateString)
                            }
                        }
                    }
                )
            }
        }
    }
    
    private func generateCalendarDays() -> [ScheduleCalendarDay] {
        var days: [ScheduleCalendarDay] = []
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart) else {
            return days
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let totalDaysInMonth = daysInMonth.count
        
        for _ in 1..<firstWeekday {
            days.append(ScheduleCalendarDay(day: 0, dateString: "", date: Date(), isCurrentMonth: false))
        }
        
        for day in 1...totalDaysInMonth {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                let dateString = dateFormatter.string(from: date)
                days.append(ScheduleCalendarDay(day: day, dateString: dateString, date: date, isCurrentMonth: true))
            }
        }
        
        return days
    }
}

private struct ScheduleCalendarDay {
    let day: Int
    let dateString: String
    let date: Date
    let isCurrentMonth: Bool
}

// MARK: - Schedule Calendar Day Cell (#D6F695 선택)
private struct ScheduleCalendarDayCell: View {
    let day: Int
    let dateString: String
    let isCurrentMonth: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if isSelected {
                    EllipticalGradient(
                        stops: [
                            .init(color: .NatureGreen, location: 0.40),
                            .init(color: .NatureGreenLight, location: 1.00)
                        ],
                        center: UnitPoint(x: 0.5, y: 0.5)
                    )
                    .frame(width: 28.ratio(), height: 28.ratio())
                    .clipShape(Circle())
                }
                
                if isCurrentMonth {
                    Text("\(day)")
                        .pretendardFont(.medium, size: 12.ratio())
                        .foregroundColor(.DarkBlack)
                }
            }
            .frame(height: 28.ratio())
        }
        .buttonStyle(.plain)
    }
}

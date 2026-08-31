//
//  ScheduleCardView.swift
//  YOGHEE
//
//  Created by 0ofKim on 3/4/26.
//

import SwiftUI

// MARK: - Schedule Card (2b 수련 카드)
struct ScheduleCardView: View {
    let schedule: NewScheduleDTO
    let onEdit: () -> Void
    let onCopy: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    /// "26년 7월 2일, 16일, 23일, 30일" 형식 (같은 월이면 월 생략)
    private var formattedDates: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let dates = schedule.dates.compactMap { formatter.date(from: $0) }.sorted()
        guard !dates.isEmpty else { return "" }
        
        let calendar = Calendar.current
        var result: [String] = []
        var currentYearMonth: (Int, Int)?
        var dayStrings: [String] = []
        
        for date in dates {
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let shortYear = year % 100
            
            if let (py, pm) = currentYearMonth, py == shortYear && pm == month {
                dayStrings.append("\(day)일")
            } else {
                if !dayStrings.isEmpty, let (py, pm) = currentYearMonth {
                    result.append("\(py)년 \(pm)월 \(dayStrings.joined(separator: ", "))")
                }
                currentYearMonth = (shortYear, month)
                dayStrings = ["\(day)일"]
            }
        }
        if !dayStrings.isEmpty, let (py, pm) = currentYearMonth {
            result.append("\(py)년 \(pm)월 \(dayStrings.joined(separator: ", "))")
        }
        return result.joined(separator: ", ")
    }
    
    private var timeRangeText: String {
        let start = schedule.startTime.timeString
        let end = schedule.endTime.timeString
        let duration = (schedule.endTime.hour * 60 + schedule.endTime.minute) -
            (schedule.startTime.hour * 60 + schedule.startTime.minute)
        return "\(start) - \(end) (\(duration)분 수업)"
    }
    
    private var capacityText: String {
        "최소 수강 인원 \(schedule.minCapacity)명 ~ 최대 \(schedule.maxCapacity)명"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12.ratio()) {
            VStack(alignment: .leading, spacing: 8.ratio()) {
                Text(schedule.name)
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.DarkBlack)
                
                Text(formattedDates)
                    .pretendardFont(.bold, size: 12)
                    .foregroundColor(.DarkBlack)
                
                HStack(spacing: 8.ratio()) {
                    Image("TimeIcon")
                        .font(.system(size: 12.ratio()))
                        .foregroundColor(.DarkBlack)
                    Text(timeRangeText)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                }
                
                HStack(spacing: 8.ratio()) {
                    Image("PeopleIcon")
                        .font(.system(size: 12.ratio()))
                        .foregroundColor(.DarkBlack)
                    Text(capacityText)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Menu {
                Button("수정") {
                    onEdit()
                }
                Button("복사") {
                    onCopy()
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Text("삭제")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14.ratio()))
                    .foregroundColor(.DarkBlack)
                    .frame(width: 24.ratio(), height: 24.ratio())
            }
        }
        .padding(12.ratio())
        .background(Color.CleanWhite)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
        .alert("수련을 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                onDelete()
            }
        }
    }
}


//
//  TodayClassesModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct TodayClassesModuleView: View {
    let classes: [YogaClassScheduleDTO]
    let onItemTap: (String) -> Void
    
    // 날짜별로 그룹화
    private var groupedClasses: [(date: String, classes: [YogaClassScheduleDTO])] {
        let grouped = Dictionary(grouping: classes) { classItem -> String in
            // day 형식: "2025-12-23" 또는 ISO8601 형식
            return formatDateLabel(from: classItem.day)
        }
        
        // 날짜 순서대로 정렬하고 tuple label 변환
        return grouped.sorted { first, second in
            // 원본 날짜로 정렬 (첫 번째 아이템의 day 사용)
            guard let firstDate = first.value.first?.day,
                  let secondDate = second.value.first?.day else {
                return false
            }
            return firstDate < secondDate
        }.map { (date: $0.key, classes: $0.value) }
    }
    
    var body: some View {
        if classes.isEmpty {
            MyPageEmptyView(message: "오늘 수업이 없습니다.")
        } else {
            VStack(spacing: 16.ratio()) {
                ForEach(groupedClasses, id: \.date) { group in
                    VStack(alignment: .leading, spacing: 12.ratio()) {
                        // 날짜 레이블
                        Text(group.date)
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.Info)
                            .padding(.horizontal, 16.ratio())
                        
                        // 해당 날짜의 수업 목록
                        VStack(spacing: 12.ratio()) {
                            ForEach(group.classes, id: \.classId) { item in
                                YogaClassScheduleItemView(
                                    item: item,
                                    onTap: { onItemTap(item.classId) },
                                    userRole: .instructor,
                                    onAttendanceCheckTap: {
                                        print("출석 체크 화면 이동")
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16.ratio())
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Helper Methods
    
    /// 날짜 문자열을 "12월 21일" 형태로 포맷
    private func formatDateLabel(from dateString: String) -> String {
        // ISO8601 형식 또는 "YYYY-MM-DD" 형식 파싱
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        var date: Date?
        
        // ISO8601 형식 시도
        if let isoDate = formatter.date(from: dateString) {
            date = isoDate
        } else {
            // "YYYY-MM-DD" 형식 시도
            let simpleDateFormatter = DateFormatter()
            simpleDateFormatter.dateFormat = "yyyy-MM-dd"
            date = simpleDateFormatter.date(from: dateString)
        }
        
        guard let validDate = date else {
            return dateString
        }
        
        // "12월 21일" 형식으로 변환
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR")
        outputFormatter.dateFormat = "M월 d일"
        
        return outputFormatter.string(from: validDate)
    }
}

#Preview {
    TodayClassesModuleView(
        classes: [
            YogaClassScheduleDTO(
                classId: "1",
                className: "자연에서 즐기는 야외 요가",
                day: "2025-12-21",
                dayOfWeek: 6,
                thumbnailUrl: "https://via.placeholder.com/160",
                address: "서울 관악구",
                attendance: 23,
                isPast: false,
                categories: ["하루수련"]
            ),
            YogaClassScheduleDTO(
                classId: "2",
                className: "하타",
                day: "2025-12-21",
                dayOfWeek: 6,
                thumbnailUrl: "https://via.placeholder.com/160",
                address: "정규수련 | 나머지 지도자",
                attendance: 23,
                isPast: false,
                categories: []
            ),
            YogaClassScheduleDTO(
                classId: "3",
                className: "자연에서 즐기는 야외 요가",
                day: "2025-12-22",
                dayOfWeek: 0,
                thumbnailUrl: "https://via.placeholder.com/160",
                address: "서울 관악구",
                attendance: 23,
                isPast: false,
                categories: []
            ),
            YogaClassScheduleDTO(
                classId: "4",
                className: "저녁 릴랙스 요가",
                day: "2025-12-23",
                dayOfWeek: 1,
                thumbnailUrl: "https://via.placeholder.com/160",
                address: "서울시 강남구",
                attendance: 15,
                isPast: false,
                categories: []
            )
        ],
        onItemTap: { classId in
            print("클래스 선택: \(classId)")
        }
    )
}

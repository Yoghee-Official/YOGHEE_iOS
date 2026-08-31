//
//  WeekClassesModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct WeekClassesModuleView: View {
    let weekDay: [YogaClassScheduleDTO]?
    let weekEnd: [YogaClassScheduleDTO]?
    let onItemTap: (String) -> Void
    
    var body: some View {
        if (weekDay?.isEmpty ?? true) && (weekEnd?.isEmpty ?? true) {
            MyPageEmptyView(message: "예약된 수련이 없습니다.")
        } else {
            VStack(spacing: 16.ratio()) {
                // 평일 수업
                if let weekDay = weekDay, !weekDay.isEmpty {
                    VStack(alignment: .leading, spacing: 12.ratio()) {
                        Text("평일")
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.Info)
                            .padding(.horizontal, 16.ratio())
                        
                        VStack(spacing: 12.ratio()) {
                            ForEach(weekDay, id: \.classId) { item in
                                YogaClassScheduleItemView(item: item, onTap: { onItemTap(item.classId) })
                            }
                        }
                        .padding(.horizontal, 16.ratio())
                    }
                }
                
                // 주말 수업
                if let weekEnd = weekEnd, !weekEnd.isEmpty {
                    VStack(alignment: .leading, spacing: 12.ratio()) {
                        Text("주말")
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.Info)
                            .padding(.horizontal, 16.ratio())
                        
                        VStack(spacing: 12.ratio()) {
                            ForEach(weekEnd, id: \.classId) { item in
                                YogaClassScheduleItemView(item: item, onTap: { onItemTap(item.classId) })
                            }
                        }
                        .padding(.horizontal, 16.ratio())
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    WeekClassesModuleView(
        weekDay: [
            YogaClassScheduleDTO(
                classId: "1",
                className: "아침 요가 클래스",
                day: "2025-12-23",
                dayOfWeek: 1,
                thumbnailUrl: "https://via.placeholder.com/160",
                address: "서울시 강남구 테헤란로 123",
                attendance: 5,
                isPast: false,
                categories: []
            ),
            YogaClassScheduleDTO(
                classId: "2",
                className: "저녁 요가 클래스",
                day: "2025-12-24",
                dayOfWeek: 2,
                thumbnailUrl: "https://via.placeholder.com/160",
                address: "서울시 강남구 역삼동 456",
                attendance: 8,
                isPast: true,
                categories: []
            ),
            YogaClassScheduleDTO(
                classId: "3",
                className: "힐링 요가",
                day: "2025-12-25",
                dayOfWeek: 3,
                thumbnailUrl: "https://via.placeholder.com/160",
                address: "서울시 서초구 서초동 789",
                attendance: 12,
                isPast: true,
                categories: []
            )
        ],
        weekEnd: [
            YogaClassScheduleDTO(
                classId: "4",
                className: "주말 특별 요가",
                day: "2025-12-27",
                dayOfWeek: 6,
                thumbnailUrl: "https://via.placeholder.com/160",
                address: "서울시 강남구 논현동 321",
                attendance: 15,
                isPast: true,
                categories: []
            ),
            YogaClassScheduleDTO(
                classId: "5",
                className: "일요일 릴랙스 요가",
                day: "2025-12-28",
                dayOfWeek: 0,
                thumbnailUrl: "https://via.placeholder.com/160",
                address: "서울시 강남구 신사동 654",
                attendance: 10,
                isPast: true,
                categories: []
            )
        ],
        onItemTap: { classId in
            print("클래스 선택: \(classId)")
        }
    )
}

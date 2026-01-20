//
//  ThisWeekClassModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct ThisWeekClassModuleView: View {
    let weekDay: [YogaClassScheduleDTO]?
    let weekEnd: [YogaClassScheduleDTO]?
    let onItemTap: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16.ratio()) {
            // 평일 수업
            if let weekDay = weekDay, !weekDay.isEmpty {
                VStack(alignment: .leading, spacing: 12.ratio()) {
                    Text("평일")
                        .pretendardFont(.bold, size: 16)
                        .foregroundColor(.DarkBlack)
                        .padding(.horizontal, 16.ratio())
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12.ratio()) {
                            ForEach(weekDay, id: \.classId) { item in
                                YogaClassScheduleItemView(item: item, onTap: { onItemTap(item.classId) })
                            }
                        }
                        .padding(.horizontal, 16.ratio())
                    }
                }
            }
            
            // 주말 수업
            if let weekEnd = weekEnd, !weekEnd.isEmpty {
                VStack(alignment: .leading, spacing: 12.ratio()) {
                    Text("주말")
                        .pretendardFont(.bold, size: 16)
                        .foregroundColor(.DarkBlack)
                        .padding(.horizontal, 16.ratio())
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12.ratio()) {
                            ForEach(weekEnd, id: \.classId) { item in
                                YogaClassScheduleItemView(item: item, onTap: { onItemTap(item.classId) })
                            }
                        }
                        .padding(.horizontal, 16.ratio())
                    }
                }
            }
        }
        .padding(.vertical, 12.ratio())
    }
}

#Preview {
    ThisWeekClassModuleView(
        weekDay: [],
        weekEnd: [],
        onItemTap: { _ in }
    )
}

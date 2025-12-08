//
//  TodayClassModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

struct TodayClassModuleView: View {
    let items: [TodayClassDTO]
    let onItemTap: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 첫 번째 아이템의 텍스트를 표시
            let displayText: String = "오늘 예약된 수련이 없습니다."
//            if let firstItem = items.first {
//                displayText = "\(firstItem.className) (\(firstItem.startTime) - \(firstItem.endTime))"
//            } else {
//                displayText = "오늘 예약된 수련이 없습니다."
//            }
            
            HStack {
                Text(displayText)
                    .pretendardFont(.regular, size: 14)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(Color.GheeYellow)
            .cornerRadius(21)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 7.5)
    }
}

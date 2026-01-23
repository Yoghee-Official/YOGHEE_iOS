//
//  YogaClassScheduleItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct YogaClassScheduleItemView: View {
    let item: YogaClassScheduleDTO
    let onTap: () -> Void
    
    private let cardHeight: CGFloat = 74.ratio()
    
    private var backgroundColor: Color {
        item.isPast ? .Background : .GheeYellow
    }
    
    /// 요일 문자열 변환 (1=월요일, 2=화요일, ..., 7=일요일)
    private var dayOfWeekString: String {
        let weekdays = ["", "mon", "tue", "wed", "thu", "fri", "sat", "sun"]
        guard item.dayOfWeek >= 1 && item.dayOfWeek <= 7 else { return "" }
        return weekdays[item.dayOfWeek]
    }
    
    /// 날짜 숫자만 추출 (예: "2025-12-24" -> "24")
    private var dayNumber: String {
        let components = item.day.split(separator: "-")
        return components.count >= 3 ? String(components[2]) : ""
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 배경 색상
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 8.ratio()))
                
                HStack(spacing: 13.ratio()) {
                    // 왼쪽: 날짜/요일 배지
                    VStack(spacing: 0) {
                        Text(dayNumber)
                            .pretendardFont(.bold, size: 20)
                            .foregroundColor(.DarkBlack)
                        Text(dayOfWeekString)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                    }
                    .frame(width: 36.ratio(), height: 53.ratio())
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 19.5))
                    
                    // 중앙: 클래스 정보
                    VStack(alignment: .leading, spacing: 4.5) {
                        Text(item.className)
                            .pretendardFont(.bold, size: 12)
                            .foregroundColor(.DarkBlack)
                            .lineLimit(1)
                        
                        HStack(spacing: 6.ratio()) {
                            Text(item.address)
                                .pretendardFont(.medium, size: 10)
                                .foregroundColor(.DarkBlack)
                            
                            // 구분선
                            Rectangle()
                                .fill(Color.DarkBlack)
                                .frame(width: 1, height: 10.ratio())
                            
                            Text("수련 인원 \(item.attendance)명")
                                .pretendardFont(.medium, size: 10)
                                .foregroundColor(.DarkBlack)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 오른쪽: 썸네일 이미지
                    AsyncImage(url: URL(string: item.thumbnailUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 48.ratio(), height: 48.ratio())
                    .clipShape(Circle())
                }
                .padding(.horizontal, 16.ratio())
                .padding(.vertical, 10.ratio())
            }
            .frame(height: cardHeight)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12.ratio()) {
        // 오늘 날짜 (GheeYellow 배경)
        YogaClassScheduleItemView(
            item: YogaClassScheduleDTO(
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
            onTap: {}
        )
        
        // 일반 날짜 (Background 배경)
        YogaClassScheduleItemView(
            item: YogaClassScheduleDTO(
                classId: "2",
                className: "자연에서 즐기는 야외 요가",
                day: "2025-12-25",
                dayOfWeek: 5,
                thumbnailUrl: "https://via.placeholder.com/48",
                address: "서울 관악구",
                attendance: 23,
                isPast: true,
                categories: []
            ),
            onTap: {}
        )
    }
    .padding()
    .background(Color.SandBeige)
}

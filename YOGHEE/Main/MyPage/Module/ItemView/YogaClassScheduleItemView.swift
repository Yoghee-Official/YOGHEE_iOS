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
    
    private let cardWidth: CGFloat = 160.ratio()
    private let cardHeight: CGFloat = 200.ratio()
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8.ratio()) {
                // 썸네일 이미지
                AsyncImage(url: URL(string: item.thumbnailUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: cardWidth, height: cardWidth)
                .clipShape(RoundedRectangle(cornerRadius: 8.ratio()))
                
                // 클래스 정보
                VStack(alignment: .leading, spacing: 4.ratio()) {
                    Text(item.className)
                        .pretendardFont(.bold, size: 14)
                        .foregroundColor(.DarkBlack)
                        .lineLimit(2)
                    
                    Text(item.address)
                        .pretendardFont(.regular, size: 12)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    HStack(spacing: 4.ratio()) {
                        Text("출석")
                            .pretendardFont(.regular, size: 12)
                            .foregroundColor(.gray)
                        Text("\(item.attendance)회")
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: cardWidth)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    YogaClassScheduleItemView(
        item: YogaClassScheduleDTO(
            classId: "1",
            className: "요가 클래스",
            day: "2025-12-21",
            dayOfWeek: 1,
            thumbnailUrl: "",
            address: "서울시 강남구",
            attendance: 10
        ),
        onTap: {}
    )
}

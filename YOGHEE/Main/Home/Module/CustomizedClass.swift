//
//  CustomizedClass.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

struct CustomizedClassModuleView: View {
    let items: [any HomeSectionItem]
    let onItemTap: (String) -> Void
    
    private let cardWidth: CGFloat = 145
    private let cardHeight: CGFloat = 225
    
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            // 수평 스크롤 카드 리스트
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items.indices, id: \.self) { index in
                        CustomizedClassCardView(
                            item: items[index],
                            onTap: { onItemTap(items[index].id) }
                        )
                        .frame(width: cardWidth, height: cardHeight)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: cardHeight)
        }
    }
}

// MARK: - Customized Class Card View
struct CustomizedClassCardView: View {
    let item: any HomeSectionItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 썸네일 이미지
                AsyncImage(url: URL(string: item.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 145, height: 145)
                .clipShape(RoundedRectangle(cornerRadius: 8))
//                .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 2) 높이 이슈로 일단 주석
                
                // 텍스트 정보 영역
                VStack(alignment: .leading, spacing: 0) {
                    // 강사명 (10px, Regular) - CustomizedClass에서 masterId 사용
                    if let customizedClass = item as? CustomizedClass {
                        Text("T. \(customizedClass.masterId)")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .frame(height: 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("T. 명요가 원장")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .frame(height: 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // 클래스 제목 (12px, Bold)
                    Text(item.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .frame(height: 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 평점 (10px, Regular)
                    if let customizedClass = item as? CustomizedClass {
                        Text("★ \(String(format: "%.1f", customizedClass.rating)) (\(customizedClass.review.formatted()))")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.black)
                            .frame(height: 24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(width: 145, alignment: .leading)
                
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
    }
}

//
//  ClassItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

enum ClassItemViewType {
    case CustomizedClass
    case HotClass
}

struct ClassItemView: View {
    let type: ClassItemViewType
    let item: any HomeSectionItem
    let ranking: Int?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 썸네일 이미지
                ZStack(alignment: .topLeading) {
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
                    
                    // HotClass인 경우에만 랭킹 배지 표시
                    if type == .HotClass, let rank = ranking {
                        RankingBadgeView(rank: rank)
                            .offset(x: 7, y: 7)
                    }
                }
                
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

// MARK: - Ranking Badge View
struct RankingBadgeView: View {
    let rank: Int
    
    var body: some View {
        ZStack {
            // 배경 (빨간색 원)
            Circle()
                .fill(Color(red: 1.0, green: 0.33, blue: 0.13))
                .frame(width: 24, height: 24)
            
            // 랭킹 숫자 (흰색)
            Text("\(rank)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

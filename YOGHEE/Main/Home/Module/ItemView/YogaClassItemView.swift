//
//  YogaClassItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

// MARK: - YogaClass Item View
struct YogaClassItemView: View {
    let yogaClass: ClassDTO
    let ranking: Int?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 썸네일 이미지
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: yogaClass.thumbnail)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 145, height: 145)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // 랭킹이 있는 경우 랭킹 배지 표시
                    if let rank = ranking {
                        RankingBadgeView(rank: rank)
                            .offset(x: 7, y: 7)
                    }
                }
                
                // 텍스트 정보 영역
                VStack(alignment: .leading, spacing: 0) {
                    // 강사명 (10px, Regular)
                    Text("T. \(yogaClass.masterName)")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .frame(height: 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 클래스 제목 (12px, Bold)
                    Text(yogaClass.className)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .frame(height: 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 평점 (10px, Regular)
                    Text("★ \(String(format: "%.1f", yogaClass.rating)) (\(yogaClass.review.formatted()))")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.black)
                        .frame(height: 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
            Image("RankingIcon")
                .resizable()
                .frame(width: 20, height: 20)
            
            Text("\(rank)")
                .font(.system(size: 12))
                .foregroundColor(Color.DarkBlack)
        }
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

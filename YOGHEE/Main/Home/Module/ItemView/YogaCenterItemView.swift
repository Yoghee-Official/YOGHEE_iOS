//
//  YogaCenterItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/8/25.
//

import SwiftUI

// MARK: - YogaCenter Item View
struct YogaCenterItemView: View {
    let yogaCenter: CenterDTO
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 썸네일 이미지
                AsyncImage(url: URL(string: yogaCenter.thumbnail)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 145, height: 145)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 텍스트 정보 영역
                VStack(alignment: .leading, spacing: 0) {
                    // 주소 (10px, Regular)
                    Text(yogaCenter.address)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .frame(height: 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 센터 제목 (12px, Bold)
                    Text(yogaCenter.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .frame(height: 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 관심 수 (10px, Regular)
                    HStack(spacing: 4) {
                        Image("FavoriteIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 9)
                        
                        Text("\(yogaCenter.favoriteCount.formatted())")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.black)
                            .frame(height: 24)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: 145, alignment: .leading)
                
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
    }
}

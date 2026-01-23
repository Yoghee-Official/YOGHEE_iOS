//
//  FavoriteRegularClassItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct FavoriteRegularClassItemView: View {
    let item: ClassDTO
    let onTap: () -> Void
    
    private let cardWidth: CGFloat = 160.ratio()
    private let cardHeight: CGFloat = 220.ratio()
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8.ratio()) {
                // 썸네일 이미지
                AsyncImage(url: URL(string: item.thumbnail)) { image in
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
                    
                    Text(item.masterName ?? "")
                        .pretendardFont(.regular, size: 12)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    HStack(spacing: 4.ratio()) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                        Text(String(format: "%.1f", item.rating ?? 0.0))
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                        Text("(\(item.review))")
                            .pretendardFont(.regular, size: 12)
                            .foregroundColor(.gray)
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
    FavoriteRegularClassItemView(
        item: ClassDTO(
            classId: "1",
            className: "요가 클래스",
            thumbnail: "",
            masterId: "1",
            masterName: "마스터 이름",
            rating: 4.5,
            review: 100,
            categories: []
        ),
        onTap: {}
    )
}

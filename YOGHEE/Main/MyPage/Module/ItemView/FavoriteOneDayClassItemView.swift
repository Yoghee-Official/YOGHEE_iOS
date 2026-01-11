//
//  FavoriteOneDayClassItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct FavoriteOneDayClassItemView: View {
    let item: FavoriteOneDayClassDTO
    let onTap: () -> Void
    
    private let cardWidth: CGFloat = 160.ratio()
    private let cardHeight: CGFloat = 220.ratio()
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8.ratio()) {
                // 썸네일 이미지
                AsyncImage(url: URL(string: item.image)) { image in
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
                    
                    if let masterName = item.masterName {
                        Text(masterName)
                            .pretendardFont(.regular, size: 12)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    if let rating = item.rating, let review = item.review {
                        HStack(spacing: 4.ratio()) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                            Text(String(format: "%.1f", rating))
                                .pretendardFont(.medium, size: 12)
                                .foregroundColor(.DarkBlack)
                            Text("(\(review))")
                                .pretendardFont(.regular, size: 12)
                                .foregroundColor(.gray)
                        }
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
    FavoriteOneDayClassItemView(
        item: FavoriteOneDayClassDTO(
            classId: "1",
            className: "요가 클래스",
            image: "",
            masterId: "1",
            masterName: "마스터 이름",
            review: 10,
            rating: 4.5
        ),
        onTap: {}
    )
}

//
//  FavoriteRegularClassItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct FavoriteRegularClassItemView: View {
    let item: FavoriteRegularClassDTO
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
                    
                    if let address = item.address {
                        Text(address)
                            .pretendardFont(.regular, size: 12)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    if let favoriteCount = item.favoriteCount {
                        HStack(spacing: 4.ratio()) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                            Text("\(favoriteCount)")
                                .pretendardFont(.medium, size: 12)
                                .foregroundColor(.DarkBlack)
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
    FavoriteRegularClassItemView(
        item: FavoriteRegularClassDTO(
            classId: "1",
            className: "요가 클래스",
            image: "",
            address: "서울시 강남구",
            favoriteCount: 100
        ),
        onTap: {}
    )
}

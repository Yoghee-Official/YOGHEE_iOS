//
//  NewReview.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

// MARK: - New Review Module View
struct NewReviewModuleView: View {
    let items: [any HomeSectionItem]
    let onItemTap: (String) -> Void
    
    private let cardWidth: CGFloat = 343.ratio()
    private let cardHeight: CGFloat = 120.ratio()
    private let cardSpacing: CGFloat = 12.0
    
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: cardSpacing) {
                    ForEach(items.indices, id: \.self) { index in
                        NewReviewCardView(
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

// MARK: - New Review Card View
struct NewReviewCardView: View {
    let item: any HomeSectionItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 1) {
                // 왼쪽: 썸네일 이미지
                AsyncImage(url: URL(string: item.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 76, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 오른쪽: 리뷰 정보 영역
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        if let review = item as? Review {
                            Text(review.userUuid)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                                .lineLimit(1)
                        } else {
                            Text("yoghee.love")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        if let review = item as? Review {
                            StarRatingView(rating: review.rating)
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    // 하단: 리뷰 내용
                    Text(item.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(width: 247, height: 100)
            }
            .frame(width: 343, height: 120)
            .background(Color.white)
            .cornerRadius(8)
            .padding(10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Star Rating View
struct StarRatingView: View {
    let rating: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { index in
                Image(index < rating ? "StarRatingFull" : "StarRatingEmpty")
                    .resizable()
                    .frame(width: 14, height: 13)
            }
        }
    }
}

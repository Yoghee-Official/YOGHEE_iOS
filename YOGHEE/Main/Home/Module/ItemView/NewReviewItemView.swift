//
//  NewReviewItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

// MARK: - New Review Card View
struct NewReviewItemView: View {
    let review: YogaReviewDTO
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack() {
                // 왼쪽: 썸네일 이미지
                AsyncImage(url: URL(string: review.thumbnail)) { image in
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
                        Text(review.userUuid)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.Info)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        StarRatingView(rating: review.rating)
                    }
                    .padding(.horizontal, 10)
                    
                    // 하단: 리뷰 내용
                    Text(review.content)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(width: 247.ratio(), height: 100.ratio())
            }
            .frame(width: 343.ratio(), height: 120.ratio())
            .background(Color.CleanWhite)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 0)
            .padding(10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Star Rating View
struct StarRatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { index in
                Image(Double(index) < rating ? "StarRatingFull" : "StarRatingEmpty")
                    .resizable()
                    .frame(width: 14, height: 13)
            }
        }
    }
}

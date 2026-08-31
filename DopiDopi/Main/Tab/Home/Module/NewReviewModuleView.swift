//
//  NewReviewModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

// MARK: - 리뷰 둘러보기
struct NewReviewModuleView: View {
    let items: [YogaReviewDTO]
    let onItemTap: (String) -> Void

    private let cardWidth: CGFloat = 255
    private let cardSpacing: CGFloat = 12.0

    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: cardSpacing) {
                    ForEach(items, id: \.reviewId) { review in
                        ReviewItemCard(
                            review: review,
                            onTap: { onItemTap(review.reviewId) },
                            contentLineLimit: 5
                        )
                        .frame(width: cardWidth)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

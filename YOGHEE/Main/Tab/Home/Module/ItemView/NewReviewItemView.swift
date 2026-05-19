//
//  NewReviewItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

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

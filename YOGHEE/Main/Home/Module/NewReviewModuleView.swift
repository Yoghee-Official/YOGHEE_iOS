//
//  NewReviewModuleView.swift
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
                        NewReviewItemView(
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

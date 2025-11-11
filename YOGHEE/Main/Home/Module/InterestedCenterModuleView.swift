//
//  InterestedCenterModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/8/25.
//

import SwiftUI

struct InterestedCenterModuleView: View {
    let items: [CenterDTO]
    let onItemTap: (String) -> Void
    
    private let cardWidth: CGFloat = 145
    private let cardHeight: CGFloat = 225
    
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            // 수평 스크롤 카드 리스트
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items.indices, id: \.self) { index in
                        YogaCenterItemView(
                            yogaCenter: items[index],
                            onTap: { onItemTap(items[index].centerId) }
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

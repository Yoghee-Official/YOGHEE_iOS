//
//  TopTenModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

struct TopTenModuleView: View {
    let items: [any HomeSectionItem]
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
                        ClassItemView(
                            type: .HotClass,
                            item: items[index],
                            ranking: index + 1,
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

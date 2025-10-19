//
//  RecommendClass.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

struct RecommendClassModuleView: View {
    let items: [any HomeSectionItem]
    let onItemTap: (String) -> Void
    
    private var displayItems: [any HomeSectionItem] {
        Array(items.prefix(5))
    }
    
    private let cardWidth: CGFloat = 338.ratio()
    private let cardHeight: CGFloat = 250.ratio()
    
    var body: some View {
        if displayItems.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(displayItems.indices, id: \.self) { index in
                        RecommendRankingCardView(
                            item: displayItems[index],
                            onTap: { onItemTap(displayItems[index].id) }
                        )
                        .frame(width: cardWidth, height: cardHeight)
                    }
                }
                .padding(.horizontal, 15)
            }
            .frame(height: cardHeight)
        }
    }
}

// MARK: - Recommend Class Card View
struct RecommendRankingCardView: View {
    let item: any HomeSectionItem
    let onTap: () -> Void
    
    /// 배너 배경 컬러 팔레트
    private static let backgroundColors: [Color] = [
        Color(red: 0.85, green: 0.96, blue: 0.58), // NatureGreen
        Color(red: 1, green: 0.93, blue: 0.45),    // GheeYellow
        Color(red: 1, green: 0.33, blue: 0.13),    // MindOrange
        Color(red: 0.79, green: 0.88, blue: 0.99), // FlowBlue
        Color(red: 0.37, green: 0.28, blue: 0.21), // LandBrown
        Color(red: 0.94, green: 0.93, blue: 0.92), // Notice
        Color(red: 0.9, green: 0.7, blue: 0.8),    // 추가 컬러 1
        Color(red: 0.7, green: 0.9, blue: 0.8),    // 추가 컬러 2
        Color(red: 0.8, green: 0.8, blue: 0.9)     // 추가 컬러 3
    ]
    
    /// 타이틀 (최대 10자)
    private var displayTitle: String {
        item.title.count > 10 ? String(item.title.prefix(9)) + "…" : item.title
    }
    
    /// 서브타이틀 (최대 20자)
    private var displaySubtitle: String {
        let subtitle = (item as? YogaClass)?.description ?? "YOGHEE 추천 수업"
        return subtitle.count > 20 ? String(subtitle.prefix(19)) + "…" : subtitle
    }
    
    /// ID 기반 배경 컬러
    private var backgroundColor: Color {
        Self.backgroundColors[abs(item.id.hashValue) % Self.backgroundColors.count]
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .top) {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 0)
                
                VStack(spacing: 8) {
                    Text(displayTitle)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.988, green: 0.980, blue: 0.957))
                    
                    Text(displaySubtitle)
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.988, green: 0.980, blue: 0.957))
                }
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.horizontal, 16)
            }
        }
        .buttonStyle(.plain)
    }
}

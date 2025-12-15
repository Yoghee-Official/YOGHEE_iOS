//
//  ImageBannerModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

struct MainBannerModuleView: View {
    let items: [MainBannerClassDTO]
    let onItemTap: (String) -> Void
    
    private var displayItems: [MainBannerClassDTO] {
        Array(items.prefix(5))
    }
    
    private let cardWidth: CGFloat = 338.ratio()
    private let cardHeight: CGFloat = 250.ratio()
    
    var body: some View {
        if displayItems.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(displayItems.indices, id: \.self) { index in
                        RecommendRankingCardView(
                            item: displayItems[index],
                            onTap: { onItemTap(displayItems[index].classId) }
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

// MARK: - Recommend Class Card View
struct RecommendRankingCardView: View {
    let item: MainBannerClassDTO
    let onTap: () -> Void
    
    /// 배너 배경 컬러 팔레트
    private static let backgroundColors: [Color] = [
        Color.GheeYellow,
        Color.NatureGreen,
        Color.MindOrange,
        Color.LandBrown,
        Color.FlowBlue,
        Color.Notice,
        Color.Info,
        Color.CleanWhite,
        Color.DarkBlack,
        Color.SandBeige
    ]
    
    /// 타이틀 (최대 10자)
    private var displayTitle: String {
        item.className.count > 10 ? String(item.className.prefix(9)) + "…" : item.className
    }
    
    /// 서브타이틀 (최대 20자)
    private var displaySubtitle: String {
        let subtitle = item.description
        return subtitle.count > 20 ? String(subtitle.prefix(19)) + "…" : subtitle
    }
    
    /// ID 기반 배경 컬러
    private var backgroundColor: Color {
        Self.backgroundColors[abs(item.classId.hashValue) % Self.backgroundColors.count]
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .top) {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                VStack(spacing: 8) {
                    Text(displayTitle)
                        .pretendardFont(.bold, size: 20)
                        .foregroundStyle(Color.SandBeige)
                    
                    Text(displaySubtitle)
                        .pretendardFont(.regular, size: 10)
                        .foregroundStyle(Color.SandBeige)
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

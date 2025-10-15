//
//  HomeTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

// MARK: - Home Tab View
struct HomeTabView: View {
    @StateObject private var container = HomeTabContainer()
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                HeaderView(container: container, navigationPath: $navigationPath)
                    .frame(height: 60)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        if container.state.isLoading {
                            ProgressView("데이터 로딩 중...")
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else if let errorMessage = container.state.errorMessage {
                            VStack(spacing: 16) {
                                Text("오류가 발생했습니다")
                                    .font(.headline)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Button("다시 시도") {
                                    container.handleIntent(.loadMainData)
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            ForEach(container.state.sections) { section in
                                SectionView(section: section) { itemId in
                                    container.handleIntent(.selectItem(itemId, section.type))
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .notifications:
                    NotificationListView()
                case .classDetail(let classId):
                    Text("클래스 상세: \(classId)")
                case .reviewDetail(let reviewId):
                    Text("리뷰 상세: \(reviewId)")
                case .categoryDetail(let categoryId):
                    Text("카테고리 상세: \(categoryId)")
                }
            }
        }
    }
}




// MARK: - Header View
struct HeaderView: View {
    @ObservedObject var container: HomeTabContainer
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        HStack(spacing: 15) {
            // 로고
            Image("HeaderLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 28)
            
            // 토글 버튼 그룹
            HStack(spacing: 0) {
                ToggleButton(
                    title: "하루수련",
                    isSelected: container.state.selectedTrainingMode == .oneDay,
                    action: {
                        container.handleIntent(.toggleTrainingMode(.oneDay))
                    }
                )
                
                ToggleButton(
                    title: "정규수련",
                    isSelected: container.state.selectedTrainingMode == .regular,
                    action: {
                        container.handleIntent(.toggleTrainingMode(.regular))
                    }
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            
            Spacer()
            
            // 알림 아이콘
            Button(action: {
                navigationPath.append(NavigationDestination.notifications)
            }) {
                Image("NotificationButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 27)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
    }
}

// MARK: - Toggle Button
struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 71.5, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.NatureGreen : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Section View
struct SectionView: View {
    let section: HomeSection
    let onItemTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 타이틀 영역만 좌우 15px 여백
            HStack {
                Text(section.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Button("더보기") {
                    // TODO: 더보기 액션
                }
                .font(.system(size: 14))
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 15)
            
            // 배너 영역은 VStack 여백 0, 내부 배너가 좌우 15px 가짐
            switch section.type {
            case .recommendClass:
                RecommendRankingModuleView(items: section.items, onItemTap: onItemTap)
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Recommend Ranking Module View  
struct RecommendRankingModuleView: View {
    let items: [any HomeSectionItem]
    let onItemTap: (String) -> Void
    
    /// 최대 5개까지만 표시
    private var displayItems: [any HomeSectionItem] {
        Array(items.prefix(5))
    }
    
    /// 배너 크기 (375pt 기준 338x250)
    private let cardWidth: CGFloat = 338.0
    private let cardHeight: CGFloat = 250.0
    
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

// MARK: - Recommend Ranking Card View
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

#Preview {
    HomeTabView(navigationPath: .constant(NavigationPath()))
}

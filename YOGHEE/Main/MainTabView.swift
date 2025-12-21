//
//  MainTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

// MARK: - Main Tab Container
struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @State private var homeNavigationPath = NavigationPath()
    @State private var isTabBarHiddenByScroll = false
    
    var body: some View {
        ZStack {
            // 현재 선택된 탭의 뷰 표시
            allTabViews
            
            // Floating Tab Bar - 1뎁스에서만 표시
            VStack {
                Spacer()
                if shouldShowTabBar {
                    FloatingTabBar(selectedTab: $selectedTab)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: shouldShowTabBar)
        }
    }
    
    // TabBar 표시 여부 결정 (1뎁스에서만 표시)
    private var shouldShowTabBar: Bool {
        // 스크롤로 숨김 상태면 무조건 숨김
        if isTabBarHiddenByScroll {
            return false
        }
        
        switch selectedTab {
        case .home:
            return homeNavigationPath.count == 0
        case .content, .explore, .teatime, .mypage:
            return true // 다른 탭들은 현재 네비게이션이 없으므로 항상 표시
        }
    }
    
    //TODO: 너비를 탭 마다 독립적으로 가져갈지 고민해보기
    @ViewBuilder
    private var allTabViews: some View {
        HomeTabView(navigationPath: $homeNavigationPath, isTabBarHidden: $isTabBarHiddenByScroll)
            .opacity(selectedTab == .home ? 1 : 0)
            .allowsHitTesting(selectedTab == .home)
        
        ContentTabView()
            .opacity(selectedTab == .content ? 1 : 0)
            .allowsHitTesting(selectedTab == .content)
        
        ExploreTabView()
            .opacity(selectedTab == .explore ? 1 : 0)
            .allowsHitTesting(selectedTab == .explore)
        
        TeaTimeTabView()
            .opacity(selectedTab == .teatime ? 1 : 0)
            .allowsHitTesting(selectedTab == .teatime)
        
        MyPageTabView()
            .opacity(selectedTab == .mypage ? 1 : 0)
            .allowsHitTesting(selectedTab == .mypage)
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: TabItem
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabBarItem(tab: tab, isSelected: selectedTab == tab) {
                    selectedTab = tab
                    #if DEBUG
                    print("\(tab.title) 탭 클릭됨")
                    #endif
                }
            }
        }
        .padding(.horizontal, 23)
        .padding(.vertical, 0)
        .background(
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.white)
                .frame(height: 68)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
        )
    }
}

// MARK: - Tab Item
enum TabItem: CaseIterable {
    case home
    case content
    case explore
    case teatime
    case mypage
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .content: return "Content"
        case .explore: return "Explore"
        case .teatime: return "Tea time"
        case .mypage: return "My page"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .content: return "eye.fill"
        case .explore: return "location.fill"
        case .teatime: return "message.fill"
        case .mypage: return "person.fill"
        }
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .pretendardFont(.medium, size: 20)
                    .foregroundColor(isSelected ? .black : .gray.opacity(0.6))
                
                Text(tab.title)
                    .pretendardFont(.medium, size: 11)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
}

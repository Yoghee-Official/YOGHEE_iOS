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
    
    var body: some View {
        ZStack {
            // 현재 선택된 탭의 뷰 표시
            allTabViews
            
            // Floating Tab Bar - 1뎁스에서만 표시
            if shouldShowTabBar {
                VStack {
                    Spacer()
                    FloatingTabBar(selectedTab: $selectedTab)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 40)
                }
            }
        }
    }
    
    // TabBar 표시 여부 결정 (1뎁스에서만 표시)
    private var shouldShowTabBar: Bool {
        switch selectedTab {
        case .home:
            return homeNavigationPath.count == 0
        case .content, .explore, .teatime, .mypage:
            return true // 다른 탭들은 현재 네비게이션이 없으므로 항상 표시
        }
    }
    
    @ViewBuilder
    private var allTabViews: some View {
        // Home Tab
        HomeTabView(navigationPath: $homeNavigationPath)
            .opacity(selectedTab == .home ? 1 : 0)
            .allowsHitTesting(selectedTab == .home)
        
        // Content Tab
        ContentTabView()
            .opacity(selectedTab == .content ? 1 : 0)
            .allowsHitTesting(selectedTab == .content)
        
        // Explore Tab
        ExploreTabView()
            .opacity(selectedTab == .explore ? 1 : 0)
            .allowsHitTesting(selectedTab == .explore)
        
        // TeaTime Tab
        TeaTimeTabView()
            .opacity(selectedTab == .teatime ? 1 : 0)
            .allowsHitTesting(selectedTab == .teatime)
        
        // MyPage Tab
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
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .black : .gray.opacity(0.6))
                
                Text(tab.title)
                    .font(.system(size: 11, weight: .medium))
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

//
//  HomeTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI
import Foundation

struct HomeTabView: View {
    @StateObject private var container = HomeTabContainer()
    @Binding var navigationPath: NavigationPath
    @Binding var isTabBarHidden: Bool
    @State private var initialOffset: CGFloat?
    @State private var contentHeight: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                HomeHeaderView(container: container, navigationPath: $navigationPath)
                    .frame(height: 60)
                
                GeometryReader { scrollGeometry in
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
                                    SectionView(
                                        section: section,
                                        selectedClassType: container.state.selectedClassType
                                    ) { itemId in
                                        container.handleIntent(.selectItem(itemId, section.id))
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onAppear {
                                        initialOffset = geometry.frame(in: .global).minY
                                        contentHeight = geometry.size.height
                                    }
                                    .onChange(of: geometry.size.height) { _, newHeight in
                                        contentHeight = newHeight
                                    }
                                    .onChange(of: geometry.frame(in: .global).minY) { oldValue, newValue in
                                        guard let initial = initialOffset else { return }
                                        
                                        let scrollableDistance = max(0, contentHeight - scrollViewHeight)
                                        let minOffset = initial - scrollableDistance
                                        
                                        // 최상단 오프셋보다 위로는 무시
                                        if newValue > initial {
//                                            print("newValue: \(newValue)")
//                                            print("initial: \(initial)")
                                            return
                                        }
                                        ////////////////////////////////////////////////////////////////////
                                        //TODO: 여기 offset 좀 수정해보기
                                        ////////////////////////////////////////////////////////////////////
                                        print("newValue: \(newValue)")
                                        print("minOffset: \(minOffset)")
                                        // 최하단 오프셋보다 아래로는 무시
                                        if newValue <= minOffset+80 {
                                            isTabBarHidden = true
                                            return
                                        }
                                        
                                        // 유효한 스크롤 범위에서만 방향 감지
                                        let delta = newValue - oldValue
                                        
                                        if abs(delta) > 0.5 {
                                            if delta < 0 {
                                                print("스크롤 Down")
                                                isTabBarHidden = true
                                            } else {
                                                print("스크롤 Up")
                                                isTabBarHidden = false
                                            }
                                        }
                                    }
                            }
                        )
                    }
                    .onAppear {
                        scrollViewHeight = scrollGeometry.size.height
                    }
                    .onChange(of: scrollGeometry.size.height) { _, newHeight in
                        scrollViewHeight = newHeight
                    }
                }
            }
            .background(Color.SandBeige)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .notifications:
                    NotificationListView()
                case .classDetail(let classId):
                    Text("클래스 상세: \(classId)")
                case .reviewDetail(let reviewId):
                    Text("리뷰 상세: \(reviewId)")
                case .categoryDetail(let categoryId, let categoryName, let categoryType, let categories):
                    CategoryMainView(
                        categoryId: categoryId,
                        categoryName: categoryName,
                        categoryType: categoryType,
                        categories: categories
                    )
                }
            }
            .onChange(of: container.state.navigationDestination) { _, newValue in
                if let destination = newValue {
                    navigationPath.append(destination)
                    // Intent를 통해 네비게이션 State 초기화
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        container.handleIntent(.clearNavigation)
                    }
                }
            }
        }
    }
}

// MARK: - Section View
struct SectionView: View {
    let section: HomeSection
    let selectedClassType: ClassType
    let onItemTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !section.title.isEmpty {
                HStack {
                    Text(section.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16) // TODO: 임의로 16 준 상태인데, 모듈 마다 위 아래 패딩(간격) 다르게 줄 수 있도록 고안해봐야할듯
            }
            
            switch section {
            case .todayClass(_, let items):
                TodayClassModuleView(items: items, onItemTap: onItemTap)
            case .imageBanner(_, let items):
                ImageBannerModuleView(items: items, onItemTap: onItemTap)
            case .interestedClass(_, let items):
                InterestedClassModuleView(items: items, onItemTap: onItemTap)
            case .interestedCenter(_, let items):
                InterestedCenterModuleView(items: items, onItemTap: onItemTap)
            case .top10Class(_, let items):
                TopTenClassModuleView(items: items, onItemTap: onItemTap)
            case .top10Center(_, let items):
                TopTenCenterModuleView(items: items, onItemTap: onItemTap)
            case .newReview(_, let items):
                NewReviewModuleView(items: items, onItemTap: onItemTap)
            case .yogaCategory(_, let items):
                switch selectedClassType {
                case .oneDay:
                    OneDayCategoryModuleView(items: items, onItemTap: onItemTap)
                case .regular:
                    RegularCategoryModuleView(items: items, onItemTap: onItemTap)
                }
            }
        }
    }
}

#Preview {
    HomeTabView(navigationPath: .constant(NavigationPath()), isTabBarHidden: .constant(false))
}

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
    /// 오늘의 수련 모듈 클릭 시 마이페이지 탭으로 이동
    let onNavigateToMyPage: () -> Void
    @State private var initialOffset: CGFloat?
    @State private var contentHeight: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                HomeHeaderView(container: container, navigationPath: $navigationPath)
                    .frame(height: 91)
                
                GeometryReader { scrollGeometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            if container.state.isLoading {
                                // 헤더를 제외한 스크롤 영역 전체(뷰포트 높이)를 채우는 로딩 화면
                                LoadingView()
                                    .frame(width: scrollGeometry.size.width, height: scrollGeometry.size.height)
                            } else if let errorMessage = container.state.errorMessage {
                                VStack(spacing: 16) {
                                    Text("오류가 발생했습니다")
                                        .pretendardFont(.semiBold, size: 17)
                                    Text(errorMessage)
                                        .pretendardFont(.regular, size: 12)
                                        .foregroundColor(.gray)
                                    Button("다시 시도") {
                                        container.handleIntent(.loadMainData)
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .frame(maxWidth: .infinity, minHeight: 200)
                            } else {
                                ForEach(Array(container.state.sections.enumerated()), id: \.element.id) { index, section in
                                    SectionView(
                                        section: section,
                                        selectedClassType: container.state.selectedClassType,
                                        onTodayClassTap: onNavigateToMyPage
                                    ) { itemId in
                                        container.handleIntent(.selectItem(itemId, section.id))
                                    }
                                    .padding(.vertical, sectionInternalPadding(section))
                                    .padding(.top, sectionTopSpacing(index: index, sections: container.state.sections))
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
                    MessageBoxView()
                case .classDetail(let classId):
                    ClassDetailView(classId: classId)
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
    /// 오늘의 수련 모듈 전용 탭 콜백 (마이페이지 랜딩)
    let onTodayClassTap: () -> Void
    let onItemTap: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !section.title.isEmpty {
                HStack {
                    Text(section.title)
                        .pretendardFont(.bold, size: 20)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16) // TODO: 임의로 16 준 상태인데, 모듈 마다 위 아래 패딩(간격) 다르게 줄 수 있도록 고안해봐야할듯
            }

            switch section {
            case .todayClass(_, let item):
                TodayClassModuleView(item: item, onTap: onTodayClassTap)
            case .imageBanner(_, let items):
                MainBannerModuleView(items: items, onItemTap: onItemTap)
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

// MARK: - Section Spacing Helpers
extension HomeTabView {
    private func sectionInternalPadding(_ section: HomeSection) -> CGFloat {
        switch section {
        case .todayClass, .imageBanner: return 8
        default: return 0
        }
    }

    private func sectionTopSpacing(index: Int, sections: [HomeSection]) -> CGFloat {
        guard index > 0 else { return 0 }

        let currentSection = sections[index]
        let prevSection = sections[index - 1]

        if case .imageBanner = currentSection { return 0 }
        if case .imageBanner = prevSection { return 24 }

        let bannerIdx = sections.firstIndex { if case .imageBanner = $0 { return true }; return false }
        guard let bannerIdx, index > bannerIdx else { return 0 }
        return 56
    }
}

#Preview {
    HomeTabView(navigationPath: .constant(NavigationPath()), isTabBarHidden: .constant(false), onNavigateToMyPage: {})
}

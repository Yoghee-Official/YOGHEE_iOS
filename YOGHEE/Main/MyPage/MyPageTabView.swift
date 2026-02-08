//
//  MyPageTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI
import SwiftUIIntrospect

struct MyPageTabView: View {
    @StateObject private var container = MyPageTabContainer()
    @ObservedObject private var authManager = AuthManager.shared
    @State private var navigationPath = NavigationPath()
    let isSelected: Bool  // 탭이 선택되었는지 여부
    var onNavigateToHome: (() -> Void)? = nil  // 홈으로 이동하는 클로저
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // StatusBar 영역만 색상 변경 (role에 따라)
                    VStack(spacing: 0) {
                        (container.state.currentRole == .yogini ? Color.GheeYellow : Color.FlowBlue)
                            .frame(height: geometry.safeAreaInsets.top)
                        
                        Color.SandBeige
                    }
                    .ignoresSafeArea()
                    
                    // 메인 컨텐츠
                    ScrollView {
                        if container.state.isLoading {
                            ProgressView("데이터 로딩 중...")
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else if let errorMessage = container.state.errorMessage {
                            VStack(spacing: 16) {
                                Text("오류가 발생했습니다")
                                    .pretendardFont(.semiBold, size: 17)
                                Text(errorMessage)
                                    .pretendardFont(.regular, size: 12)
                                    .foregroundColor(.gray)
                                Button("다시 시도") {
                                    container.handleIntent(.loadMyPageData)
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            LazyVStack(spacing: 20) {
                                ForEach(container.state.sections) { section in
                                    MyPageSectionView(
                                        section: section,
                                        container: container,
                                        onItemTap: { itemId, sectionId in
                                            container.handleIntent(.selectItem(itemId, sectionId))
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .introspect(.scrollView, on: .iOS(.v18)) { scrollView in
                        scrollView.bounces = false
                    }
                }
            }
            .navigationDestination(for: MyPageNavigationDestination.self) { destination in
                switch destination {
                case .settings:
                    SettingsView()
                case .messageBox:
                    MessageBoxView()
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
        .onChange(of: isSelected) { newValue in
            // 탭이 선택될 때만 로그인 체크
            if newValue {
                container.handleIntent(.checkLoginStatus)
            }
        }
        .sheet(isPresented: $container.showLoginSheet) {
            LoginView()
        }
        .onChange(of: container.showLoginSheet) { isPresented in
            // 로그인 창이 닫혔을 때 (로그인 안 했으면 홈으로 이동)
            // 로그인 성공 후 sheet가 닫힐 때도 실행 될 수 있기 때문에 안전하게 !container.state.isLoggedIn 추가 -> TODO: 굳이 필요 없는건지는 추후 확인 필요
            if !isPresented && !authManager.isAuthenticated && !container.state.isLoggedIn {
                onNavigateToHome?()
            }
        }
        .onChange(of: authManager.isAuthenticated) { newValue in
            // 로그인 완료 시 sheet 닫고 데이터 로딩
            if newValue && container.showLoginSheet {
                container.onLoginSuccess()
            }
        }
        .fullScreenCover(isPresented: $container.showProfileEditSheet) {
            ProfileEditView(
                currentProfileImage: container.state.myPageData?.userProfile?.profileImage,
                onApply: { selectedImage in
                    if let image = selectedImage {
                        print("✅ 선택된 이미지: \(image.size)")
                        // TODO: 서버에 이미지 업로드 API 호출
                        // TODO: 업로드 성공 후 프로필 데이터 새로고침
                    }
                }
            )
        }
    }
}

// MARK: - Section View
struct MyPageSectionView: View {
    let section: MyPageSection
    let container: MyPageTabContainer
    let onItemTap: (String, String) -> Void  // itemId, sectionId
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 헤더 (title이 있을 때만 표시)
            if !section.title.isEmpty {
                MyPageSectionHeaderView(
                    title: section.title,
                    titleType: section.titleType,
                    isYogini: Binding(
                        get: { container.state.currentRole == .yogini },
                        set: { isYogini in
                            let newRole: UserRole = isYogini ? .yogini : .instructor
                            container.handleIntent(.switchRole(newRole))
                        }
                    ),
                    onMoreButtonTap: {
                        // TODO: 목록 더보기 액션 처리
                        print("목록 더보기 클릭: \(section.id)")
                    }
                )
            }
            
            switch section {
            case .profile:
                // 요기니 프로필
                if let userProfile = container.state.myPageData?.userProfile {
                    UserProfileModuleView(
                        profileData: userProfile,
                        onProfileEditTap: {
                            container.handleIntent(.editProfile)
                        },
                        onSettingTap: {
                            container.handleIntent(.openSettings)
                        },
                        onNotificationTap: {
                            container.handleIntent(.openNotifications)
                        },
                        onLevelInfoTap: {
                            container.handleIntent(.viewLevelInfo)
                        },
                        onCategoryTap: {
                            container.handleIntent(.viewCategoryAnalysis)
                        }
                    )
                }
                // 지도자 프로필
                else if let leaderProfile = container.state.myPageData?.leaderProfile {
                    LeaderProfileModuleView(
                        profileData: leaderProfile,
                        onProfileEditTap: {
                            container.handleIntent(.editProfile)
                        },
                        onSettingTap: {
                            container.handleIntent(.openSettings)
                        },
                        onNotificationTap: {
                            container.handleIntent(.openNotifications)
                        },
                        onLevelInfoTap: {
                            // TODO: 지도자 자격증 상세 화면 이동
                            print("지도자 자격증 상세 클릭")
                        },
                        onCategoryTap: {
                            // TODO: 지도자 카테고리 분석 화면 이동
                            print("지도자 카테고리 분석 클릭")
                        }
                    )
                }
                
            case .weekClasses(let weekDay, let weekEnd):
                WeekClassesModuleView(
                    weekDay: weekDay,
                    weekEnd: weekEnd,
                    onItemTap: { itemId in onItemTap(itemId, section.id) }
                )
                
            case .todayClasses(let classes):
                // 지도자 전용 - 오늘의 수업 (TODO: TodayClassesModuleView 구현 필요)
                // 임시로 ReservedClassesModuleView 재사용
                ReservedClassesModuleView(
                    classes: classes,
                    onItemTap: { itemId in onItemTap(itemId, section.id) }
                )
                
            case .reservedClasses(let classes):
                ReservedClassesModuleView(
                    classes: classes,
                    onItemTap: { itemId in onItemTap(itemId, section.id) }
                )
                
            case .favoriteClasses(let classes):
                FavoriteClassModuleView(
                    classes: classes,
                    onItemTap: { itemId in onItemTap(itemId, section.id) }
                )
                
            case .favoriteCenters(let centers):
                FavoriteCenterModuleView(
                    centers: centers,
                    onItemTap: { itemId in onItemTap(itemId, section.id) }
                )
                
            case .detailContents:
                DetailContentsModuleView { itemName in
                    container.handleIntent(.selectDetailItem(itemName))
                }
            }
        }
    }
}

#Preview {
    MyPageTabView(isSelected: false, onNavigateToHome: nil)
}

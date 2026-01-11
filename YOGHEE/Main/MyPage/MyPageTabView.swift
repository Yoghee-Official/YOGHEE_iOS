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
    let isSelected: Bool  // 탭이 선택되었는지 여부
    var onNavigateToHome: (() -> Void)? = nil  // 홈으로 이동하는 클로저
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // StatusBar 영역만 색상 변경
                VStack(spacing: 0) {
                    Color.GheeYellow
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
            if !section.title.isEmpty {
                HStack {
                    Text(section.title)
                        .pretendardFont(.bold, size: 16)
                        .foregroundColor(.DarkBlack)
                }
                .frame(height: 32)
                .padding(.horizontal, 24)
            }
            
            switch section {
            case .profile:
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
                
            case .weekClasses(let weekDay, let weekEnd):
                WeekClassesModuleView(
                    weekDay: weekDay,
                    weekEnd: weekEnd,
                    onItemTap: { itemId in onItemTap(itemId, section.id) }
                )
                
            case .reservedClasses(let classes):
                ReservedClassesModuleView(
                    classes: classes,
                    onItemTap: { itemId in onItemTap(itemId, section.id) }
                )
                
            case .favoriteOneDayClasses(let classes):
                FavoriteOneDayClassesModuleView(
                    classes: classes,
                    onItemTap: { itemId in onItemTap(itemId, section.id) }
                )
                
            case .favoriteRegularClasses(let classes):
                FavoriteRegularClassesModuleView(
                    classes: classes,
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

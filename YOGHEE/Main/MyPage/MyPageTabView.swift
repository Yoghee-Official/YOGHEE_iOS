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
                    // TODO: [로그인 화면] 나중에 활성화
                    // if container.state.showLoginSheet {
                    //     LoginView { userId, password in
                    //         container.handleIntent(.login(userId: userId, password: password))
                    //     }
                    // } else
                    
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
                    } else if let myPageData = container.state.myPageData {
                        VStack(spacing: 0) {
                            // 사용자 프로필 모듈
                            UserProfileModuleView(
                                profileData: myPageData,
                                onProfileEditTap: {
                                    print("프로필 편집 클릭")
                                },
                                onSettingTap: {
                                    // TODO: [로그아웃] 나중에 로그아웃 기능 추가
                                    // container.handleIntent(.logout)
                                    print("설정 클릭")
                                },
                                onNotificationTap: {
                                    print("알림 클릭")
                                },
                                onLevelInfoTap: {
                                    print("레벨 정보 클릭")
                                },
                                onCategoryTap: {
                                    print("카테고리 분석 클릭")
                                }
                            )
                            
                            // 세부 항목 모듈
                            DetailContentsView { itemName in
                                container.handleIntent(.selectDetailItem(itemName))
                            }
                            
                            // TODO: [API 연동] 추가 모듈들 (내 수업, 내 리뷰 등)
                        }
                        .padding(.top, 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .introspect(.scrollView, on: .iOS(.v18)) { scrollView in
                    scrollView.bounces = false
                }
            }
        }
    }
}

// TODO: [API 연동] MyPageSectionView 구현 (HomeTabView의 SectionView 참고)

#Preview {
    MyPageTabView()
}

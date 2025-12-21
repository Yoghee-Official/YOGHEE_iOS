//
//  MyPageTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

struct MyPageTabView: View {
    @StateObject private var container = MyPageTabContainer()
    
    // TODO: [API 연동] 실제 데이터로 교체
    private let mockProfileData = UserProfileData(
        userName: "앨리스",
        profileImageUrl: nil,
        totalHours: 203,
        upcomingClasses: 6,
        currentLevel: 5,
        timeToNextLevel: "55분",
        topCategory: "하타",
        categoryCount: 25
    )
    
    var body: some View {
        ScrollView {
            // TODO: [API 연동] 로딩/에러 상태 처리 추가 (HomeTabView 참고)
            
            VStack(spacing: 20) {
                // TODO: [API 연동] 동적 섹션 렌더링으로 변경 (ForEach sections)
                
                // 사용자 프로필 모듈
                UserProfileModuleView(
                    profileData: mockProfileData,
                    onProfileEditTap: {
                        print("프로필 편집 클릭")
                    },
                    onSettingTap: {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
    }
}

// TODO: [API 연동] MyPageSectionView 구현 (HomeTabView의 SectionView 참고)

#Preview {
    MyPageTabView()
}

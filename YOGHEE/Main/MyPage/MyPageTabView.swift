//
//  MyPageTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

struct MyPageTabView: View {
    @StateObject private var container = MyPageTabContainer()
    
    var body: some View {
        ScrollView {
            // TODO: [API 연동] 로딩/에러 상태 처리 추가 (HomeTabView 참고)
            
            VStack(spacing: 20) {
                // TODO: [API 연동] 동적 섹션 렌더링으로 변경 (ForEach sections)
                
                // 현재는 고정 모듈만 노출 (임시)
                DetailContentsView { itemName in
                    container.handleIntent(.selectDetailItem(itemName))
                }
                
                // TODO: [API 연동] 추가 모듈들 (사용자 프로필, 내 수업, 내 리뷰 등)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
    }
}

// TODO: [API 연동] MyPageSectionView 구현 (HomeTabView의 SectionView 참고)

#Preview {
    MyPageTabView()
}

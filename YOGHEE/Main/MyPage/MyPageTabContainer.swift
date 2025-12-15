//
//  MyPageTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Intent
enum MyPageTabIntent {
    case selectDetailItem(String)
    // TODO: [API 연동] loadMyPageData, 프로필 수정, 로그아웃 등 Intent 추가
}

// MARK: - State
struct MyPageTabState: Equatable {
    var selectedDetailItem: String?
    // TODO: [API 연동] sections, isLoading, errorMessage 등 추가
}

// TODO: [API 연동] MyPageSection enum 정의 (HomeSection 참고)

@MainActor
class MyPageTabContainer: ObservableObject {
    @Published private(set) var state = MyPageTabState()
    
    init() {
        // TODO: [API 연동] loadMyPageData() 호출
    }
    
    func handleIntent(_ intent: MyPageTabIntent) {
        switch intent {
        case .selectDetailItem(let itemName):
            state.selectedDetailItem = itemName
            print("\(itemName) 클릭")
            // TODO: 각 항목별 네비게이션 처리
        // TODO: [API 연동] case .loadMyPageData 처리 추가
        }
    }
    
    // TODO: [API 연동] loadMyPageData() 메서드 구현 (HomeTabContainer 참고)
    // TODO: [API 연동] createSections() 메서드 구현
}

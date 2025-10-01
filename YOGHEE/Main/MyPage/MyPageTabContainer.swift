//
//  MyPageTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Intent
enum MyPageTabIntent {
    // TODO: MyPage 관련 Intent 추가
}

// MARK: - State
struct MyPageTabState: Equatable {
    // TODO: MyPage 관련 상태 추가
}

@MainActor
class MyPageTabContainer: ObservableObject {
    @Published private(set) var state = MyPageTabState()
    
    init() {
        // TODO: 초기화 로직
    }
    
    func handleIntent(_ intent: MyPageTabIntent) {
        // TODO: Intent 처리 로직
    }
}

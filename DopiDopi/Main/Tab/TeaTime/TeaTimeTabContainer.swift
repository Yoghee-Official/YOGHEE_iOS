//
//  TeaTimeTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Intent
enum TeaTimeTabIntent {
    // TODO: TeaTime 관련 Intent 추가
}

// MARK: - State
struct TeaTimeTabState: Equatable {
    // TODO: TeaTime 관련 상태 추가
}

@MainActor
class TeaTimeTabContainer: ObservableObject {
    @Published private(set) var state = TeaTimeTabState()
    
    init() {
        // TODO: 초기화 로직
    }
    
    func handleIntent(_ intent: TeaTimeTabIntent) {
        // TODO: Intent 처리 로직
    }
}

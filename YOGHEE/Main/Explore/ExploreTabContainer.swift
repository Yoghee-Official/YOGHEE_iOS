//
//  ExploreTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Intent
enum ExploreTabIntent {
    // TODO: Explore 관련 Intent 추가
}

// MARK: - State
struct ExploreTabState: Equatable {
    // TODO: Explore 관련 상태 추가
}

@MainActor
class ExploreTabContainer: ObservableObject {
    @Published private(set) var state = ExploreTabState()
    
    init() {
        // TODO: 초기화 로직
    }
    
    func handleIntent(_ intent: ExploreTabIntent) {
        // TODO: Intent 처리 로직
    }
}

//
//  ContentTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Intent
enum ContentTabIntent {
    // TODO: Content 관련 Intent 추가
}

// MARK: - State
struct ContentTabState: Equatable {
    // TODO: Content 관련 상태 추가
}

@MainActor
class ContentTabContainer: ObservableObject {
    @Published private(set) var state = ContentTabState()
    
    init() {
        // TODO: 초기화 로직
    }
    
    func handleIntent(_ intent: ContentTabIntent) {
        // TODO: Intent 처리 로직
    }
}

//
//  NotificationListContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/2/25.
//

import SwiftUI

// MARK: - Intent
enum NotificationListIntent {
    // TODO: Notification 관련 Intent 추가
}

// MARK: - State
struct NotificationListState: Equatable {
    // TODO: Notification 관련 상태 추가
}

@MainActor
class NotificationListContainer: ObservableObject {
    @Published private(set) var state = NotificationListState()
    
    init() {
        // TODO: 초기화 로직
    }
    
    func handleIntent(_ intent: NotificationListIntent) {
        // TODO: Intent 처리 로직
    }
}
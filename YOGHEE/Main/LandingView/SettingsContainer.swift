//
//  SettingsContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 1/24/26.
//

import SwiftUI

// MARK: - Intent
enum SettingsIntent {
    case loadSettings
    case togglePushNotification(Bool)
    case logout
    case deleteAccount
    // TODO: 추가 Intent
}

// MARK: - State
struct SettingsState: Equatable {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isPushNotificationEnabled: Bool = true
    // TODO: 설정 관련 상태 추가
}

@MainActor
class SettingsContainer: ObservableObject {
    @Published private(set) var state = SettingsState()
    
    init() {
        // TODO: 초기화 로직
        loadSettings()
    }
    
    func handleIntent(_ intent: SettingsIntent) {
        switch intent {
        case .loadSettings:
            loadSettings()
        case .togglePushNotification(let isEnabled):
            togglePushNotification(isEnabled: isEnabled)
        case .logout:
            logout()
        case .deleteAccount:
            deleteAccount()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSettings() {
        // TODO: 설정 로드
    }
    
    private func togglePushNotification(isEnabled: Bool) {
        // TODO: 푸시 알림 설정 변경
        state.isPushNotificationEnabled = isEnabled
    }
    
    private func logout() {
        // TODO: 로그아웃 처리
    }
    
    private func deleteAccount() {
        // TODO: 계정 삭제
    }
}

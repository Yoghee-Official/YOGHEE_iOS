//
//  SettingsContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 1/24/26.
//

import SwiftUI
import UIKit
import UserNotifications

// MARK: - Intent
enum SettingsIntent {
    case loadSettings
    case toggleMarketingNotification(Bool)
    case openMemberInfo
    case tapAppPermissionSettings
    case dismissNotificationPermissionAlert
    case dismissAppPermissionAlert
    case openSystemSettings
}

// MARK: - State
struct SettingsState: Equatable {
    var isMarketingNotificationEnabled: Bool = false
    var showNotificationPermissionAlert: Bool = false
    var showAppPermissionAlert: Bool = false
    var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    var isLatestVersion: Bool = true
}

@MainActor
class SettingsContainer: ObservableObject {
    @Published private(set) var state = SettingsState()

    init() {
        loadSettings()
    }

    func handleIntent(_ intent: SettingsIntent) {
        switch intent {
        case .loadSettings:
            loadSettings()
        case .toggleMarketingNotification(let isEnabled):
            handleMarketingToggle(isEnabled: isEnabled)
        case .openMemberInfo:
            print("👤 [Settings] 회원 정보 관리 클릭 - TODO: MI_MO_1 이동")
        case .tapAppPermissionSettings:
            state.showAppPermissionAlert = true
        case .dismissNotificationPermissionAlert:
            state.showNotificationPermissionAlert = false
        case .dismissAppPermissionAlert:
            state.showAppPermissionAlert = false
        case .openSystemSettings:
            openSystemSettings()
        }
    }

    // MARK: - Private

    private func loadSettings() {
        state.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
        // TODO: API로 최신 버전 체크
        print("🔄 [Settings] loadSettings - 현재 버전: \(state.appVersion), TODO: API로 최신 버전 체크")
    }

    private func handleMarketingToggle(isEnabled: Bool) {
        guard isEnabled else {
            state.isMarketingNotificationEnabled = false
            return
        }
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            switch settings.authorizationStatus {
            case .notDetermined:
                let granted = (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
                state.isMarketingNotificationEnabled = granted
                if !granted { state.showNotificationPermissionAlert = true }
            case .authorized, .provisional, .ephemeral:
                state.isMarketingNotificationEnabled = true
            case .denied:
                state.showNotificationPermissionAlert = true
                state.isMarketingNotificationEnabled = false
            @unknown default:
                break
            }
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

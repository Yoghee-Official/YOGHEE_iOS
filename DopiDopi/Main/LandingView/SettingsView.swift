//
//  SettingsView.swift
//  YOGHEE
//
//  Created by 0ofKim on 1/24/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var container = SettingsContainer()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                loginSection
                notificationSection
                otherSection
                versionSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(Color.SandBeige.ignoresSafeArea())
        .customNavigationBar(title: "설정")
        .alert("알림 설정", isPresented: Binding(
            get: { container.state.showNotificationPermissionAlert },
            set: { _ in container.handleIntent(.dismissNotificationPermissionAlert) }
        )) {
            Button("취소", role: .cancel) {}
            Button("설정으로 이동") { container.handleIntent(.openSystemSettings) }
        } message: {
            Text("알림을 사용하려면 기기 설정에서\n알림을 허용해 주세요.")
        }
        .alert("앱 접근 권한 설정", isPresented: Binding(
            get: { container.state.showAppPermissionAlert },
            set: { _ in container.handleIntent(.dismissAppPermissionAlert) }
        )) {
            Button("취소", role: .cancel) {}
            Button("설정으로 이동") { container.handleIntent(.openSystemSettings) }
        } message: {
            Text("앱 접근 권한을 설정하려면\n기기 설정으로 이동합니다.")
        }
    }

    // MARK: - Sections

    private var loginSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("로그인 설정")
            settingsCard {
                staticRow(title: "자동 로그인", value: "켜짐")
                rowDivider
                chevronRow(title: "회원 정보 관리") {
                    container.handleIntent(.openMemberInfo) // TODO: MI_MO_1 이동
                }
            }
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("알림 설정")
            Text("알림을 켜두시면 할인 정보 및 이벤트 혜택을 알려드립니다!")
                .pretendardFont(.regular, size: 12)
                .foregroundColor(.MindOrange)
            settingsCard {
                marketingToggleRow
            }
        }
    }

    private var otherSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("기타 설정")
            settingsCard {
                chevronRow(title: "앱 접근 권한 설정") {
                    container.handleIntent(.tapAppPermissionSettings)
                }
            }
        }
    }

    private var versionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("버전 정보")
            settingsCard {
                versionRow
            }
        }
    }

    // MARK: - Rows

    private var marketingToggleRow: some View {
        HStack(spacing: 4) {
            Text("(선택) 마케팅 수신 동의")
                .pretendardFont(.medium, size: 16)
                .foregroundColor(.DarkBlack)
            Button("보기") {
                // TODO: 마케팅 수신 동의 팝업 노출
                print("📋 [Settings] 마케팅 수신 동의 보기 클릭")
            }
            .pretendardFont(.medium, size: 14)
            .foregroundColor(.MindOrange)
            Spacer()
            Toggle("", isOn: Binding(
                get: { container.state.isMarketingNotificationEnabled },
                set: { container.handleIntent(.toggleMarketingNotification($0)) }
            ))
            .labelsHidden()
            .tint(.MindOrange)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }

    private var versionRow: some View {
        HStack {
            Text("현재 버전 v\(container.state.appVersion)")
                .pretendardFont(.medium, size: 16)
                .foregroundColor(.DarkBlack)
            Spacer()
            if let latestVersion = container.state.latestVersion, isLatestVersion(container.state.appVersion, latestVersion) {
                Text("최신 버전 입니다.")
                    .pretendardFont(.regular, size: 14)
                    .foregroundColor(.Info)
            } else {
                Button("업데이트 하기") {
                    // TODO: 앱스토어 이동
                    print("🛒 [Settings] 업데이트 하기 클릭")
                }
                .pretendardFont(.medium, size: 14)
                .foregroundColor(.MindOrange)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }

    private func isLatestVersion(_ currentVersion: String, _ latestVersion: String) -> Bool {
        let currentParts = currentVersion.split(separator: ".").compactMap { Int($0) }
        let latestParts = latestVersion.split(separator: ".").compactMap { Int($0) }

        for (current, latest) in zip(currentParts, latestParts) {
            if current < latest { return false }
            if current > latest { return true }
        }
        return currentParts.count >= latestParts.count
    }

    // MARK: - Common Components

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .pretendardFont(.bold, size: 16)
            .foregroundColor(.DarkBlack)
    }

    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color.CleanWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func staticRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .pretendardFont(.medium, size: 16)
                .foregroundColor(.DarkBlack)
            Spacer()
            Text(value)
                .pretendardFont(.regular, size: 14)
                .foregroundColor(.Info)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }

    private func chevronRow(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .pretendardFont(.medium, size: 16)
                    .foregroundColor(.DarkBlack)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.Info)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
        }
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.Notice)
            .frame(height: 1)
            .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

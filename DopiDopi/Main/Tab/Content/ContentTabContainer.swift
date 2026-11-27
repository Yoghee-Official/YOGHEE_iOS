//
//  ContentTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Intent
enum ContentTabIntent {
    case loadFeed
    /// 당겨서 새로고침 - 기존 피드를 유지한 채 다시 불러옴
    case refresh
}

// MARK: - State
struct ContentTabState: Equatable {
    var weekLabel: String = ""
    var items: [FeedItemDTO] = []
    var isLoading: Bool = false
    /// 당겨서 새로고침 진행 중 (전체 화면 로딩 없이 기존 피드 유지)
    var isRefreshing: Bool = false
    var isEmpty: Bool = false
    /// 피드 로드 실패 시 노출할 연결 오류 화면 (404 '이번 주 피드 없음'은 빈 상태로 처리하므로 제외)
    var connectionError: ConnectionErrorKind?
}

@MainActor
class ContentTabContainer: ObservableObject {
    @Published private(set) var state = ContentTabState()

    init() {
        loadFeed()
    }

    func handleIntent(_ intent: ContentTabIntent) {
        switch intent {
        case .loadFeed:
            loadFeed()
        case .refresh:
            guard !state.isLoading, !state.isRefreshing else { return }
            loadFeed(isRefresh: true)
        }
    }

    private func loadFeed(isRefresh: Bool = false) {
        if isRefresh {
            state.isRefreshing = true
        } else {
            state.isLoading = true
            state.isEmpty = false
        }

        Task { @MainActor in
            do {
                let response = try await APIService.shared.getFeed()
                state.weekLabel = response.data.weekLabel
                state.items = response.data.items
                state.isEmpty = false
                state.connectionError = nil
                state.isLoading = false
                state.isRefreshing = false
            } catch APIError.notFound {
                // 새로고침 중 이번 주 피드가 내려간 경우에도 빈 화면으로 바뀌도록 기존 항목을 비움
                state.items = []
                state.isEmpty = true
                state.connectionError = nil
                state.isLoading = false
                state.isRefreshing = false
            } catch {
                print("❌ 피드 로딩 실패: \(error)")
                // 비로그인(토큰 없음/만료)은 연결 오류가 아니므로 기존처럼 빈 상태로 둔다.
                // 새로고침 실패 시 기존 피드가 있으면 그대로 유지하고, 없을 때만 오류 화면 노출
                let isAuthError = (error as? APIError).map { $0 == .unauthorized || $0 == .tokenExpired } ?? false
                if !isAuthError && (!isRefresh || state.items.isEmpty) {
                    state.connectionError = .service
                }
                state.isLoading = false
                state.isRefreshing = false
            }
        }
    }
}

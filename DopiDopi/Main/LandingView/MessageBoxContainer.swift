//
//  MessageBoxContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/2/25.
//

import SwiftUI

// MARK: - Intent
enum MessageBoxIntent {
    case loadMessages
    case loadNextPage
    case selectTab(MessageBoxTab)
    /// 메세지 유닛 탭 - 접혀 있으면 상세조회(읽음 처리) 후 펼치고, 펼쳐져 있으면 접는다
    case toggleMessage(String)
    case markAllAsRead
    case deleteMessage(String)
    case dismissAlert
}

// MARK: - State
struct MessageBoxState: Equatable {
    var selectedTab: MessageBoxTab = .all
    var messages: [NotificationListItemDTO] = []
    /// 상세조회로 받아온 본문 캐시 (다시 펼칠 때 재조회하지 않음)
    var details: [String: NotificationDetailDTO] = [:]
    var expandedMessageIds: Set<String> = []
    var loadingDetailIds: Set<String> = []
    /// 서버 기준 현재 탭의 미확인 개수 (아직 불러오지 않은 페이지 포함)
    var unreadCount: Int = 0
    var page: Int = 0
    var hasNext: Bool = false
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var errorMessage: String? = nil
    /// 삭제·모두 읽음 실패 등 안내 팝업 메세지
    var alertMessage: String? = nil

    var hasUnreadMessages: Bool {
        unreadCount > 0 || messages.contains { !$0.isRead }
    }
}

@MainActor
class MessageBoxContainer: ObservableObject {
    @Published private(set) var state = MessageBoxState()

    private let pageSize = 20
    /// 탭을 빠르게 전환할 때 이전 탭 응답이 늦게 도착해 덮어쓰지 않도록 요청을 구분
    private var listRequestId = UUID()

    func handleIntent(_ intent: MessageBoxIntent) {
        switch intent {
        case .loadMessages:
            loadMessages()
        case .loadNextPage:
            loadNextPage()
        case .selectTab(let tab):
            guard tab != state.selectedTab else { return }
            state.selectedTab = tab
            loadMessages()
        case .toggleMessage(let messageId):
            toggleMessage(messageId: messageId)
        case .markAllAsRead:
            markAllAsRead()
        case .deleteMessage(let messageId):
            deleteMessage(messageId: messageId)
        case .dismissAlert:
            state.alertMessage = nil
        }
    }

    // MARK: - Private Methods

    private func loadMessages() {
        let requestId = UUID()
        listRequestId = requestId
        let tab = state.selectedTab

        state.isLoading = true
        state.errorMessage = nil
        state.expandedMessageIds = []

        Task {
            do {
                let response = try await APIService.shared.getNotifications(tab: tab, page: 0, size: pageSize)
                guard listRequestId == requestId else { return }
                state.messages = response.items
                state.unreadCount = response.unreadCount ?? 0
                state.page = response.page ?? 0
                state.hasNext = response.hasNext ?? false
                state.isLoading = false
            } catch {
                guard listRequestId == requestId else { return }
                log("❌ 메세지 목록 조회 에러: \(error)")
                state.messages = []
                state.hasNext = false
                state.errorMessage = error.localizedDescription
                state.isLoading = false
            }
        }
    }

    private func loadNextPage() {
        guard state.hasNext, !state.isLoading, !state.isLoadingMore else { return }
        let requestId = listRequestId
        let tab = state.selectedTab
        let nextPage = state.page + 1

        state.isLoadingMore = true

        Task {
            do {
                let response = try await APIService.shared.getNotifications(tab: tab, page: nextPage, size: pageSize)
                guard listRequestId == requestId else { return }
                // 페이지 사이에 삭제가 일어나면 항목이 밀려 중복될 수 있어 이미 있는 항목은 제외
                let existingIds = Set(state.messages.map(\.id))
                state.messages += response.items.filter { !existingIds.contains($0.id) }
                state.page = response.page ?? nextPage
                state.hasNext = response.hasNext ?? false
                state.isLoadingMore = false
            } catch {
                guard listRequestId == requestId else { return }
                log("❌ 메세지 다음 페이지 조회 에러: \(error)")
                state.isLoadingMore = false
            }
        }
    }

    private func toggleMessage(messageId: String) {
        if state.expandedMessageIds.contains(messageId) {
            state.expandedMessageIds.remove(messageId)
            return
        }

        state.expandedMessageIds.insert(messageId)
        // 펼치는 즉시 비활성화 컬러로 바꾸고, 서버 읽음 처리는 상세조회가 같이 해준다
        setRead(messageId: messageId)

        guard state.details[messageId] == nil, !state.loadingDetailIds.contains(messageId) else { return }
        state.loadingDetailIds.insert(messageId)

        Task {
            do {
                let detail = try await APIService.shared.getNotificationDetail(notificationId: messageId)
                state.details[messageId] = detail
            } catch {
                log("❌ 메세지 상세 조회 에러: \(error)")
                state.expandedMessageIds.remove(messageId)
                state.alertMessage = error.localizedDescription
            }
            state.loadingDetailIds.remove(messageId)
        }
    }

    private func markAllAsRead() {
        // 안읽은 메세지가 없으면 클릭해도 변화 없음
        guard state.hasUnreadMessages else { return }
        let tab = state.selectedTab

        // 화면은 바로 비활성화 컬러로 변경하고, 실패 시 목록을 다시 불러와 서버 상태로 되돌린다
        for index in state.messages.indices {
            state.messages[index].isRead = true
        }
        state.unreadCount = 0

        Task {
            do {
                _ = try await APIService.shared.readAllNotifications(tab: tab)
            } catch {
                log("❌ 메세지 모두 읽음 에러: \(error)")
                state.alertMessage = error.localizedDescription
                loadMessages()
            }
        }
    }

    private func deleteMessage(messageId: String) {
        Task {
            do {
                try await APIService.shared.hideNotification(notificationId: messageId)
                state.messages.removeAll { $0.id == messageId }
                state.expandedMessageIds.remove(messageId)
                state.details[messageId] = nil
            } catch {
                log("❌ 메세지 삭제 에러: \(error)")
                state.alertMessage = error.localizedDescription
            }
        }
    }

    private func setRead(messageId: String) {
        guard let index = state.messages.firstIndex(where: { $0.id == messageId }),
              !state.messages[index].isRead else { return }
        state.messages[index].isRead = true
        state.unreadCount = max(0, state.unreadCount - 1)
    }

    private func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}

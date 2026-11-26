//
//  MemberLookupContainer.swift
//  YOGHEE
//
//  회원 조회(SM_MO_1) - 지도자 마이페이지 > 회원 조회 모듈 "더보기"
//  - 2a 하루수련 / 정규수련 토글 (탭별로 목록·페이지를 따로 유지)
//  - 2d 더보기: 정규수련 탭에서만 노출 (하루수련은 정지 기능 없음). 활성 회원은 수강권 정지, 비활성 회원은 수강권 재개
//    정지·재개 API는 요가원(centerId) 단위라 회원 상세에서 대상 요가원을 확인한 뒤 요청한다
//

import SwiftUI

// MARK: - Intent
enum MemberLookupIntent {
    case load
    /// 당겨서 새로고침 - 현재 탭 목록을 유지한 채 첫 페이지부터 다시 불러옴
    case refresh
    /// 2a 하루수련 / 정규수련 토글
    case selectTab(MemberLookupTab)
    case loadMoreIfNeeded(currentId: String)
    case retry
    /// 2d 더보기 (nil이면 닫기)
    case toggleMoreMenu(String?)
    /// 수강권 정지/재개 클릭 → 확인 얼럿 노출
    case requestTicketAction(LeaderMemberDTO)
    case dismissTicketAction
    case confirmTicketAction
    case dismissAlert
}

// MARK: - 수강권 정지/재개
enum MemberTicketAction: Equatable {
    case pause
    case resume

    var menuTitle: String {
        switch self {
        case .pause: return "수강권 정지"
        case .resume: return "수강권 재개"
        }
    }

    /// TODO: 기획/디자인 확정 시 문구 교체 (SB에 "수강권 정지/재개 할 경우 알림창 노출" 메모만 있음)
    var confirmMessage: String {
        switch self {
        case .pause: return "수강권을 정지하시겠습니까?"
        case .resume: return "수강권을 재개하시겠습니까?"
        }
    }

    /// 회원 상세 tickets 중 이 동작의 대상이 되는 수강권 상태
    var targetTicketStatus: String {
        switch self {
        case .pause: return "ACTIVE"
        case .resume: return "PAUSED"
        }
    }

    var noTargetMessage: String {
        switch self {
        case .pause: return "정지할 수 있는 사용 중인 수강권이 없습니다."
        case .resume: return "재개할 수 있는 정지된 수강권이 없습니다."
        }
    }

    var failureMessage: String {
        switch self {
        case .pause: return "수강권 정지에 실패했습니다.\n잠시 후 다시 시도해주세요."
        case .resume: return "수강권 재개에 실패했습니다.\n잠시 후 다시 시도해주세요."
        }
    }
}

// MARK: - 탭별 목록 상태
struct MemberLookupListState: Equatable {
    var members: [LeaderMemberDTO] = []
    var nextPage: Int = 0
    var hasNext: Bool = true
    var isLoading: Bool = false
    var hasLoaded: Bool = false
    var errorMessage: String? = nil
}

// MARK: - State
struct MemberLookupState: Equatable {
    var selectedTab: MemberLookupTab = .oneDay
    var lists: [MemberLookupTab: MemberLookupListState] = [:]
    /// 당겨서 새로고침 진행 중 (전체 화면 로딩 없이 기존 목록 유지)
    var isRefreshing: Bool = false

    /// 2d 더보기 메뉴가 열린 회원
    var moreMenuMemberId: String? = nil
    var pendingMember: LeaderMemberDTO? = nil
    var isProcessing: Bool = false
    /// 정지/재개 실패 등 안내 팝업 문구
    var alertMessage: String? = nil

    var currentList: MemberLookupListState {
        lists[selectedTab] ?? MemberLookupListState()
    }

    var pendingAction: MemberTicketAction? {
        guard let pendingMember else { return nil }
        return pendingMember.isTicketPaused ? .resume : .pause
    }
}

// MARK: - Container
@MainActor
class MemberLookupContainer: ObservableObject {
    @Published private(set) var state = MemberLookupState()

    private let pageSize = 20

    func handleIntent(_ intent: MemberLookupIntent) {
        switch intent {
        case .load:
            if !state.currentList.hasLoaded { reload(state.selectedTab) }

        case .refresh:
            guard !state.currentList.isLoading, !state.isRefreshing else { return }
            loadPage(0, tab: state.selectedTab, replacing: true, isRefresh: true)

        case .selectTab(let tab):
            state.moreMenuMemberId = nil
            state.selectedTab = tab
            if !state.currentList.hasLoaded { reload(tab) }

        case .loadMoreIfNeeded(let currentId):
            let list = state.currentList
            guard currentId == list.members.last?.userUuid,
                  list.hasNext, !list.isLoading, !state.isRefreshing, list.errorMessage == nil else { return }
            loadPage(list.nextPage, tab: state.selectedTab, replacing: false)

        case .retry:
            reload(state.selectedTab)

        case .toggleMoreMenu(let memberId):
            state.moreMenuMemberId = state.moreMenuMemberId == memberId ? nil : memberId

        case .requestTicketAction(let member):
            state.moreMenuMemberId = nil
            state.pendingMember = member

        case .dismissTicketAction:
            state.pendingMember = nil

        case .confirmTicketAction:
            performTicketAction()

        case .dismissAlert:
            state.alertMessage = nil
        }
    }

    // MARK: - 목록 조회

    private func reload(_ tab: MemberLookupTab) {
        state.lists[tab] = MemberLookupListState()
        loadPage(0, tab: tab, replacing: true)
    }

    /// - Parameter isRefresh: 당겨서 새로고침. 목록 로딩 표시 없이 응답이 올 때까지 기존 목록을 유지
    private func loadPage(_ page: Int, tab: MemberLookupTab, replacing: Bool, isRefresh: Bool = false) {
        if isRefresh {
            state.isRefreshing = true
        } else {
            state.lists[tab, default: MemberLookupListState()].isLoading = true
        }

        Task {
            do {
                let result = try await APIService.shared.getLeaderMembers(type: tab.typeParameter, page: page, size: pageSize)
                var list = state.lists[tab] ?? MemberLookupListState()
                if replacing {
                    list.members = result.items
                    list.errorMessage = nil
                } else {
                    // 페이지 경계에서 중복 항목이 들어오지 않도록 걸러낸다
                    let existing = Set(list.members.map(\.userUuid))
                    list.members += result.items.filter { !existing.contains($0.userUuid) }
                }
                list.nextPage = page + 1
                list.hasNext = result.hasNext ?? false
                list.isLoading = false
                list.hasLoaded = true
                state.lists[tab] = list
                if isRefresh { state.isRefreshing = false }
                log("✅ [MemberLookup] \(tab.title) \(page)페이지 조회 완료: \(result.items.count)명 (전체 \(result.totalCount ?? 0)명)")
            } catch {
                log("❌ [MemberLookup] \(tab.title) 회원 목록 조회 실패: \(error)")
                var list = state.lists[tab] ?? MemberLookupListState()
                if replacing { list.members = [] }
                list.isLoading = false
                list.hasLoaded = true
                list.errorMessage = errorMessage(for: error, fallback: "회원 목록을 불러오지 못했습니다.")
                state.lists[tab] = list
                if isRefresh { state.isRefreshing = false }
            }
        }
    }

    // MARK: - 2d 수강권 정지 / 재개

    /// 1) 회원 상세에서 대상 수강권(정지: ACTIVE, 재개: PAUSED)의 요가원(centerId)을 모으고
    /// 2) 요가원마다 정지/재개를 요청한다. 화면은 회원 단위라 해당 회원의 모든 요가원 정규수련 수강권이 대상.
    private func performTicketAction() {
        guard let member = state.pendingMember, let action = state.pendingAction, !state.isProcessing else { return }
        state.pendingMember = nil
        state.isProcessing = true

        Task {
            defer { state.isProcessing = false }

            let centerIds: [String]
            do {
                let detail = try await APIService.shared.getLeaderMemberDetail(userUuid: member.userUuid)
                centerIds = detail.centerIds(forTicketStatus: action.targetTicketStatus)
            } catch {
                log("❌ [MemberLookup] \(action.menuTitle) 대상 확인(회원 상세) 실패: \(error)")
                state.alertMessage = errorMessage(for: error, fallback: action.failureMessage)
                return
            }

            guard !centerIds.isEmpty else {
                log("⚠️ [MemberLookup] \(action.menuTitle) 대상 수강권 없음: \(member.userUuid)")
                state.alertMessage = action.noTargetMessage
                return
            }

            var succeededCount = 0
            var lastError: Error?
            for centerId in centerIds {
                do {
                    switch action {
                    case .pause:
                        try await APIService.shared.pauseMemberTickets(userUuid: member.userUuid, centerId: centerId)
                    case .resume:
                        try await APIService.shared.resumeMemberTickets(userUuid: member.userUuid, centerId: centerId)
                    }
                    succeededCount += 1
                    log("✅ [MemberLookup] \(action.menuTitle) 완료: \(member.userUuid) / center \(centerId)")
                } catch {
                    lastError = error
                    log("❌ [MemberLookup] \(action.menuTitle) 실패: \(member.userUuid) / center \(centerId) - \(error)")
                }
            }

            // 서버 ticketPaused 기준(정지된 정규수련 수강권이 하나라도 있으면 true)에 맞춰 갱신
            switch action {
            case .pause where succeededCount > 0:
                updateTicketPaused(userUuid: member.userUuid, paused: true)
            case .resume where lastError == nil:
                updateTicketPaused(userUuid: member.userUuid, paused: false)
            default:
                break
            }

            if let lastError {
                state.alertMessage = errorMessage(for: lastError, fallback: action.failureMessage)
            }
        }
    }

    private func updateTicketPaused(userUuid: String, paused: Bool) {
        for tab in state.lists.keys {
            guard var list = state.lists[tab],
                  let index = list.members.firstIndex(where: { $0.userUuid == userUuid }) else { continue }
            list.members[index].ticketPaused = paused
            state.lists[tab] = list
        }
    }

    // MARK: - Helpers

    private func errorMessage(for error: Error, fallback: String) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .unauthorized, .tokenExpired:
                return "로그인이 필요합니다.\n다시 로그인해주세요."
            case .serverError(_, _, let message) where !message.isEmpty:
                return message
            default:
                break
            }
        }
        return fallback
    }

    private func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}

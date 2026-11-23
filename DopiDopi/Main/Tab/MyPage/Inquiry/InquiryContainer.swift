//
//  InquiryContainer.swift
//  YOGHEE
//
//  나의 문의(CS_MO_2) - 마이 탭 > 세부 항목 "나의 문의" (요기니 전용)
//  - 문의하기 탭: 카카오톡 채팅 문의(A18 얼럿) + 1:1 문의 등록
//  - 나의 문의함 탭: 내가 등록한 문의 목록 (최신순, 펼치면 내용/답변)
//

import SwiftUI
import KakaoSDKTalk

// MARK: - Tab
enum InquiryTab: CaseIterable, Equatable {
    /// 2a 문의하기 (기본 활성화)
    case inquire
    /// 2b 나의 문의함
    case myInquiries

    var title: String {
        switch self {
        case .inquire: return "문의하기"
        case .myInquiries: return "나의 문의함"
        }
    }

    /// 탭별 섹션 타이틀
    var sectionTitle: String {
        switch self {
        case .inquire: return "문의함"
        case .myInquiries: return "문의 내역"
        }
    }
}

// MARK: - Intent
enum InquiryIntent {
    case load
    case selectTab(InquiryTab)

    // 3a 카카오톡 채팅 문의
    case tapKakaoChat
    case dismissKakaoAlert
    case confirmKakaoChat

    // 4 1:1 문의하기
    case toggleCategoryDropdown
    case closeCategoryDropdown
    case selectCategory(InquiryCategoryDto)
    case updateContent(String)
    case submit

    // 5 나의 문의함
    case toggleInquiry(String)
    case loadMoreIfNeeded(currentId: String)
    case retryList

    case dismissMessage
}

// MARK: - State
struct InquiryState: Equatable {
    var selectedTab: InquiryTab = .inquire

    // 4 1:1 문의하기
    var categories: [InquiryCategoryDto] = []
    var selectedCategory: InquiryCategoryDto?
    var isCategoryDropdownOpen: Bool = false
    var content: String = ""
    var isSubmitting: Bool = false

    // 5 나의 문의함
    var inquiries: [InquiryDto] = []
    var expandedInquiryIds: Set<String> = []
    var nextPage: Int = 0
    var isLastPage: Bool = false
    var isLoadingList: Bool = false
    var hasLoadedList: Bool = false
    var listErrorMessage: String?

    var showKakaoAlert: Bool = false
    /// 확인 버튼 하나짜리 안내 팝업 (등록 완료 · 에러)
    var message: String?
    /// 문의 등록 완료 팝업 확인 시 나의 문의함으로 이동
    var moveToMyInquiriesAfterMessage: Bool = false

    /// 4c 문의 유형·내용 미작성 시 비활성화
    var canSubmit: Bool {
        selectedCategory != nil
            && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isSubmitting
    }
}

@MainActor
class InquiryContainer: ObservableObject {
    @Published private(set) var state = InquiryState()

    /// 도피도피 카카오톡 채널 ID (pf.kakao.com/_xcExhvn)
    private let kakaoChannelPublicId = "_xcExhvn"
    private let pageSize = 20

    func handleIntent(_ intent: InquiryIntent) {
        switch intent {
        case .load:
            if state.categories.isEmpty { loadCategories() }

        case .selectTab(let tab):
            state.isCategoryDropdownOpen = false
            state.selectedTab = tab
            // 2b 나의 문의함: 클릭 시 활성화되며 영역 리프레시
            if tab == .myInquiries { reloadInquiries() }

        case .tapKakaoChat:
            state.isCategoryDropdownOpen = false
            state.showKakaoAlert = true
        case .dismissKakaoAlert:
            state.showKakaoAlert = false
        case .confirmKakaoChat:
            state.showKakaoAlert = false
            openKakaoChannelChat()

        case .toggleCategoryDropdown:
            state.isCategoryDropdownOpen.toggle()
            if state.isCategoryDropdownOpen && state.categories.isEmpty { loadCategories() }
        case .closeCategoryDropdown:
            state.isCategoryDropdownOpen = false
        case .selectCategory(let category):
            state.selectedCategory = category
            state.isCategoryDropdownOpen = false
        case .updateContent(let text):
            // 4b 최대 500자 이내
            state.content = String(text.prefix(InquiryCreateDto.contentMaxLength))
        case .submit:
            submit()

        case .toggleInquiry(let inquiryId):
            if state.expandedInquiryIds.contains(inquiryId) {
                state.expandedInquiryIds.remove(inquiryId)
            } else {
                state.expandedInquiryIds.insert(inquiryId)
            }
        case .loadMoreIfNeeded(let currentId):
            guard currentId == state.inquiries.last?.inquiryId else { return }
            loadNextPage()
        case .retryList:
            reloadInquiries()

        case .dismissMessage:
            state.message = nil
            if state.moveToMyInquiriesAfterMessage {
                state.moveToMyInquiriesAfterMessage = false
                state.selectedTab = .myInquiries
                reloadInquiries()
            }
        }
    }

    // MARK: - 4a 문의 유형

    private func loadCategories() {
        Task {
            do {
                state.categories = try await APIService.shared.getInquiryCategories()
                print("✅ [Inquiry] 문의 유형 조회 완료: \(state.categories.map(\.code))")
            } catch {
                print("❌ [Inquiry] 문의 유형 조회 실패: \(error)")
            }
        }
    }

    // MARK: - 4c 문의 등록

    private func submit() {
        guard state.canSubmit, let category = state.selectedCategory else { return }
        let content = state.content.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = InquiryCreateDto(
            category: category.code,
            title: InquiryCreateDto.makeTitle(from: category),
            content: content
        )

        state.isCategoryDropdownOpen = false
        state.isSubmitting = true
        Task {
            defer { state.isSubmitting = false }
            do {
                try await APIService.shared.createInquiry(body: body)
                print("✅ [Inquiry] 문의 등록 완료")
                state.selectedCategory = nil
                state.content = ""
                state.message = "문의가 등록되었습니다."
                state.moveToMyInquiriesAfterMessage = true
            } catch {
                print("❌ [Inquiry] 문의 등록 실패: \(error)")
                state.message = errorMessage(for: error, fallback: "문의 등록에 실패했습니다.\n잠시 후 다시 시도해주세요.")
            }
        }
    }

    // MARK: - 5 나의 문의함

    private func reloadInquiries() {
        state.nextPage = 0
        state.isLastPage = false
        state.expandedInquiryIds = []
        state.listErrorMessage = nil
        loadPage(0, replacing: true)
    }

    private func loadNextPage() {
        guard !state.isLastPage, !state.isLoadingList, state.listErrorMessage == nil else { return }
        loadPage(state.nextPage, replacing: false)
    }

    private func loadPage(_ page: Int, replacing: Bool) {
        state.isLoadingList = true
        Task {
            defer { state.isLoadingList = false }
            do {
                let result = try await APIService.shared.getMyInquiries(page: page, size: pageSize)
                if replacing {
                    state.inquiries = result.content
                } else {
                    // 페이지 경계에서 중복 항목이 들어오지 않도록 걸러낸다
                    let existing = Set(state.inquiries.map(\.inquiryId))
                    state.inquiries += result.content.filter { !existing.contains($0.inquiryId) }
                }
                state.nextPage = page + 1
                state.isLastPage = result.isLast
                state.hasLoadedList = true
                print("✅ [Inquiry] 나의 문의함 \(page)페이지 조회 완료: \(result.content.count)건 (전체 \(result.totalElements ?? 0)건)")
            } catch {
                print("❌ [Inquiry] 나의 문의함 조회 실패: \(error)")
                if replacing { state.inquiries = [] }
                state.hasLoadedList = true
                state.listErrorMessage = errorMessage(for: error, fallback: "문의 내역을 불러오지 못했습니다.")
            }
        }
    }

    // MARK: - 3a 카카오톡 채팅 문의

    /// A18 확인: 카카오톡 채널 채팅 연결 (카카오톡 미설치 시 SDK가 웹으로 연결)
    private func openKakaoChannelChat() {
        TalkApi.shared.chatChannel(channelPublicId: kakaoChannelPublicId) { [weak self] error in
            guard let error else { return }
            print("❌ [Inquiry] 카카오톡 채널 채팅 연결 실패: \(error)")
            Task { @MainActor in
                self?.state.message = "카카오톡을 열 수 없습니다.\n잠시 후 다시 시도해주세요."
            }
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
}

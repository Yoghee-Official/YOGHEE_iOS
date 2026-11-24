//
//  ReviewListContainer.swift
//  YOGHEE
//

import SwiftUI

// MARK: - Sort Option

enum ReviewSortOption: String, CaseIterable {
    case recent  = "recent"
    case oldest  = "oldest"
    case desc    = "desc"
    case asc     = "asc"

    var title: String {
        switch self {
        case .recent: return "최신순"
        case .oldest: return "오래된 순"
        case .desc:   return "점수 높은 순"
        case .asc:    return "점수 낮은 순"
        }
    }
}

// MARK: - Intent

enum ReviewListIntent {
    case load
    /// 당겨서 새로고침 - 기존 목록을 유지한 채 첫 페이지부터 다시 불러옴
    case refresh
    case loadNextPage
    case changeSort(ReviewSortOption)
}

// MARK: - State

struct ReviewListState: Equatable {
    var reviews: [YogaReviewDTO] = []
    var sort: ReviewSortOption = .recent
    var currentPage: Int = 0
    var totalCount: Int = 0
    var hasNext: Bool = false
    var isLoading: Bool = false
    /// 당겨서 새로고침 진행 중 (전체 화면 로딩 없이 기존 목록 유지)
    var isRefreshing: Bool = false
    var isLoadingMore: Bool = false
    var errorMessage: String? = nil
}

// MARK: - Container

@MainActor
class ReviewListContainer: ObservableObject {
    @Published private(set) var state = ReviewListState()

    let classId: String

    init(classId: String) {
        self.classId = classId
    }

    func handleIntent(_ intent: ReviewListIntent) {
        switch intent {
        case .load:
            load(reset: true)
        case .refresh:
            guard !state.isLoading, !state.isRefreshing else { return }
            load(reset: true, isRefresh: true)
        case .loadNextPage:
            guard state.hasNext, !state.isLoadingMore, !state.isRefreshing else { return }
            load(reset: false)
        case .changeSort(let sort):
            state.sort = sort
            load(reset: true)
        }
    }

    private func load(reset: Bool, isRefresh: Bool = false) {
        if reset {
            if isRefresh {
                // 새로고침은 응답이 올 때까지 기존 목록을 그대로 보여줌
                state.isRefreshing = true
            } else {
                state.isLoading = true
                state.reviews = []
            }
            state.currentPage = 0
        } else {
            state.isLoadingMore = true
        }
        state.errorMessage = nil

        let page = reset ? 0 : state.currentPage + 1
        let sort = state.sort.rawValue

        Task { @MainActor in
            do {
                let response = try await APIService.shared.getReviews(
                    classId: classId,
                    page: page,
                    sort: sort
                )
                let dto = response.data
                if reset {
                    state.reviews = dto.reviews
                } else {
                    state.reviews += dto.reviews
                }
                state.currentPage  = dto.page
                state.totalCount   = dto.totalCount
                state.hasNext      = dto.hasNext
                state.isLoading    = false
                state.isRefreshing  = false
                state.isLoadingMore = false
            } catch {
                state.errorMessage  = error.localizedDescription
                state.isLoading     = false
                state.isRefreshing  = false
                state.isLoadingMore = false
            }
        }
    }
}

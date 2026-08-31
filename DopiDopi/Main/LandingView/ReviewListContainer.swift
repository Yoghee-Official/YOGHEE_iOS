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
        case .loadNextPage:
            guard state.hasNext, !state.isLoadingMore else { return }
            load(reset: false)
        case .changeSort(let sort):
            state.sort = sort
            load(reset: true)
        }
    }

    private func load(reset: Bool) {
        if reset {
            state.isLoading = true
            state.currentPage = 0
            state.reviews = []
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
                state.isLoadingMore = false
            } catch {
                state.errorMessage  = error.localizedDescription
                state.isLoading     = false
                state.isLoadingMore = false
            }
        }
    }
}

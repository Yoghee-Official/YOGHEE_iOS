//
//  FaqContainer.swift
//  YOGHEE
//
//  FAQ(CS_MO_1) - 마이 탭 > 세부 항목 "FAQ"
//  요기니 마이페이지에서 들어오면 target=YOGINI, 지도자 마이페이지에서 들어오면 target=LEADER 로 조회
//

import SwiftUI

// MARK: - Intent
enum FaqIntent {
    /// 진입 시 카테고리 목록 → 첫 번째 카테고리 FAQ 조회
    case load
    /// 3a 카테고리 칩 선택 (선택된 칩 재클릭 시 리프레시)
    case selectCategory(String)
    /// 3b 질문 클릭 시 펼침 / 재클릭 시 접힘
    case toggleFaq(String)
    case retry
}

// MARK: - State
struct FaqState: Equatable {
    var categories: [FaqCategoryDto] = []
    var selectedCategoryCode: String?
    var faqs: [FaqDto] = []
    /// 펼쳐진 질문 ID 목록
    var expandedFaqIds: Set<String> = []

    var isLoading: Bool = false
    var errorMessage: String?
}

@MainActor
class FaqContainer: ObservableObject {
    @Published private(set) var state = FaqState()

    private let target: FaqTarget
    /// 칩을 빠르게 연속 선택했을 때 이전 요청 결과가 덮어쓰지 않도록 마지막 요청만 반영
    private var faqTask: Task<Void, Never>?

    init(target: FaqTarget) {
        self.target = target
    }

    func handleIntent(_ intent: FaqIntent) {
        switch intent {
        case .load:
            guard state.categories.isEmpty, !state.isLoading else { return }
            loadCategories()
        case .selectCategory(let code):
            // 2a/3a: 클릭 시 해당 카테고리 활성화되며 3b 영역 리프레시
            state.selectedCategoryCode = code
            loadFaqs(category: code)
        case .toggleFaq(let faqId):
            if state.expandedFaqIds.contains(faqId) {
                state.expandedFaqIds.remove(faqId)
            } else {
                state.expandedFaqIds.insert(faqId)
            }
        case .retry:
            if let code = state.selectedCategoryCode {
                loadFaqs(category: code)
            } else {
                loadCategories()
            }
        }
    }

    // MARK: - Private

    private func loadCategories() {
        state.isLoading = true
        state.errorMessage = nil
        Task {
            do {
                let categories = try await APIService.shared.getFaqCategories()
                state.categories = categories
                print("✅ [FAQ] 카테고리 조회 완료: \(categories.map(\.code))")
                // 첫 번째 항목을 기본 선택
                if let first = categories.first {
                    state.selectedCategoryCode = first.code
                    loadFaqs(category: first.code)
                } else {
                    state.isLoading = false
                }
            } catch {
                print("❌ [FAQ] 카테고리 조회 실패: \(error)")
                state.isLoading = false
                state.errorMessage = "FAQ를 불러오지 못했습니다."
            }
        }
    }

    private func loadFaqs(category: String) {
        faqTask?.cancel()
        state.isLoading = true
        state.errorMessage = nil
        faqTask = Task {
            do {
                let faqs = try await APIService.shared.getFaqs(target: target, category: category)
                guard !Task.isCancelled, state.selectedCategoryCode == category else { return }
                state.faqs = faqs
                state.expandedFaqIds = []
                state.isLoading = false
                print("✅ [FAQ] \(target.rawValue)/\(category) 조회 완료: \(faqs.count)건")
            } catch {
                guard !Task.isCancelled, state.selectedCategoryCode == category else { return }
                print("❌ [FAQ] \(target.rawValue)/\(category) 조회 실패: \(error)")
                state.faqs = []
                state.expandedFaqIds = []
                state.isLoading = false
                state.errorMessage = "FAQ를 불러오지 못했습니다."
            }
        }
    }
}

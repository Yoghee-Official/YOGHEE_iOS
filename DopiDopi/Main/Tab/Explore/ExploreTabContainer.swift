//
//  ExploreTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Intent

enum ExploreTabIntent {
    /// 검색 버튼 탭 시 호출 — bbox와 keyword를 함께 전달
    case searchClasses(bbox: MapBoundingBox, keyword: String?)
    /// 지도 핀 탭 시 호출 — nil이면 선택 해제
    case selectClass(id: String?)
}

// MARK: - State

struct ExploreTabState: Equatable {
    var classes: [ClassMapSearchDTO] = []
    var resultState: ResultState?               // 나중에 쓸 예정 — IN_BOUNDS / OUT_OF_BOUNDS / EMPTY
    var recommendations: [ClassMapSearchDTO] = [] // 나중에 쓸 예정 — "이런 요가원은 어떠세요?"
    var selectedClassId: String? = nil          // 지도 핀 선택 상태
    var isLoading: Bool = false
    var errorMessage: String?
}

// MARK: - Container

@MainActor
class ExploreTabContainer: ObservableObject {
    @Published private(set) var state = ExploreTabState()

    func handleIntent(_ intent: ExploreTabIntent) {
        switch intent {
        case .searchClasses(let bbox, let keyword):
            searchClasses(bbox: bbox, keyword: keyword)
        case .selectClass(let id):
            state.selectedClassId = id
        }
    }

    private func searchClasses(bbox: MapBoundingBox, keyword: String?) {
        state.isLoading = true
        state.errorMessage = nil

        Task {
            do {
                let data = try await APIService.shared.searchMapClasses(bbox: bbox, keyword: keyword)
                self.state.classes        = data.results
                self.state.resultState    = data.resultState       // 나중에 쓸 예정
                self.state.recommendations = data.recommendations  // 나중에 쓸 예정
                self.state.selectedClassId = nil                   // 새 검색 시 핀 선택 초기화
                self.state.isLoading = false
                print("✅ 지도 클래스 로드 완료: \(data.results.count)개 (state: \(data.resultState.rawValue))")
            } catch {
                self.state.errorMessage = error.localizedDescription
                self.state.isLoading = false
                print("❌ 지도 클래스 로드 실패: \(error)")
            }
        }
    }
}

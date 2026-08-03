//
//  ExploreTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Intent

enum ExploreTabIntent {
    case searchClasses(bbox: MapBoundingBox)
}

// MARK: - State

struct ExploreTabState: Equatable {
    var classes: [ClassMapSearchDTO] = []
    var isLoading: Bool = false
    var errorMessage: String?
}

// MARK: - Container

@MainActor
class ExploreTabContainer: ObservableObject {
    @Published private(set) var state = ExploreTabState()

    func handleIntent(_ intent: ExploreTabIntent) {
        switch intent {
        case .searchClasses(let bbox):
            searchClasses(bbox: bbox)
        }
    }

    private func searchClasses(bbox: MapBoundingBox) {
        state.isLoading = true
        state.errorMessage = nil

        Task {
            do {
                let classes = try await APIService.shared.searchMapClasses(bbox: bbox)
                self.state.classes = classes
                self.state.isLoading = false
                print("✅ 지도 영역 클래스 로드 완료: \(classes.count)개")
            } catch {
                self.state.errorMessage = error.localizedDescription
                self.state.isLoading = false
                print("❌ 지도 영역 클래스 로드 실패: \(error)")
            }
        }
    }
}

//
//  ClassDetailContainer.swift
//  YOGHEE
//

import SwiftUI

// MARK: - Intent
enum ClassDetailIntent {
    case load(classId: String)
}

// MARK: - State
struct ClassDetailState: Equatable {
    var isLoading: Bool = true
    /// 상세 로드 실패 시 노출할 연결 오류 화면 (404 CLASS_NOT_FOUND → 페이지 연결 오류)
    var connectionError: ConnectionErrorKind?
    var detail: YogaClassDetailDTO?

    static func == (lhs: ClassDetailState, rhs: ClassDetailState) -> Bool {
        lhs.isLoading == rhs.isLoading &&
        lhs.connectionError == rhs.connectionError &&
        lhs.detail?.classId == rhs.detail?.classId
    }
}

// MARK: - Container
@MainActor
class ClassDetailContainer: ObservableObject {
    @Published private(set) var state = ClassDetailState()

    func handleIntent(_ intent: ClassDetailIntent) {
        switch intent {
        case .load(let classId):
            load(classId: classId)
        }
    }

    private func load(classId: String) {
        state.isLoading = true
        state.connectionError = nil

        Task {
            do {
                let response = try await APIService.shared.getClassDetail(classId: classId)
                self.state.detail = response.data
                self.state.isLoading = false
            } catch {
                print("❌ 클래스 상세 로딩 실패: \(error)")
                self.state.connectionError = error.connectionErrorKind
                self.state.isLoading = false
            }
        }
    }
}

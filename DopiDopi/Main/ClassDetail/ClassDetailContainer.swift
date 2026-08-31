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
    var errorMessage: String?
    var detail: YogaClassDetailDTO?

    static func == (lhs: ClassDetailState, rhs: ClassDetailState) -> Bool {
        lhs.isLoading == rhs.isLoading &&
        lhs.errorMessage == rhs.errorMessage &&
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
        state.errorMessage = nil

        Task {
            do {
                let response = try await APIService.shared.getClassDetail(classId: classId)
                self.state.detail = response.data
                self.state.isLoading = false
            } catch {
                self.state.errorMessage = error.localizedDescription
                self.state.isLoading = false
            }
        }
    }
}

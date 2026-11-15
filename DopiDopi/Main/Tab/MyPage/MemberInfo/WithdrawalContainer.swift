//
//  WithdrawalContainer.swift
//  YOGHEE
//
//  회원 탈퇴(DA_MO_1) - 마이 탭 > 설정 > 회원 정보 관리 > 회원탈퇴
//

import SwiftUI

// MARK: - Intent
enum WithdrawalIntent {
    /// 2a 탈퇴 사유 선택/해제
    case toggleReason(WithdrawalReasonType)
    /// 2b 기타 내용 입력
    case updateDetail(String)
    /// 3a 회원탈퇴 하기 → A11 얼럿
    case tapWithdraw
    case dismissConfirmAlert
    /// A11 확인 → 실제 탈퇴 (되돌릴 수 없음)
    case confirmWithdraw
    case dismissMessage
}

// MARK: - State
struct WithdrawalState: Equatable {
    /// 선택 순서 유지 (최대 3개)
    var selectedReasons: [WithdrawalReasonType] = []
    var detail: String = ""

    var isSubmitting: Bool = false
    var showConfirmAlert: Bool = false
    var message: String?

    var trimmedDetail: String {
        detail.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func isSelected(_ reason: WithdrawalReasonType) -> Bool {
        selectedReasons.contains(reason)
    }
}

@MainActor
class WithdrawalContainer: ObservableObject {
    @Published private(set) var state = WithdrawalState()

    /// 탈퇴 완료 후 처리 (마이 탭 스택 초기화 + 로그인 화면 노출)
    private let onWithdrawalCompleted: () -> Void

    init(onWithdrawalCompleted: @escaping () -> Void) {
        self.onWithdrawalCompleted = onWithdrawalCompleted
    }

    func handleIntent(_ intent: WithdrawalIntent) {
        switch intent {
        case .toggleReason(let reason):
            toggle(reason)
        case .updateDetail(let text):
            updateDetail(text)
        case .tapWithdraw:
            validateAndConfirm()
        case .dismissConfirmAlert:
            state.showConfirmAlert = false
        case .confirmWithdraw:
            withdraw()
        case .dismissMessage:
            state.message = nil
        }
    }

    // MARK: - Private

    /// 2a: 선택 시 체크, 재선택 시 해제, 최대 3개
    private func toggle(_ reason: WithdrawalReasonType) {
        if let index = state.selectedReasons.firstIndex(of: reason) {
            state.selectedReasons.remove(at: index)
            return
        }
        guard state.selectedReasons.count < WithdrawalReasonType.maxSelection else {
            state.message = "탈퇴 사유는 최대 \(WithdrawalReasonType.maxSelection)개까지 선택할 수 있어요."
            return
        }
        state.selectedReasons.append(reason)
    }

    /// 2b: 기타 내용 작성 시 2a에 기타 자동 선택 (최대 3개 안에 자리가 있을 때)
    private func updateDetail(_ text: String) {
        state.detail = String(text.prefix(WithdrawalRequestDto.maxDetailLength))
        let hasDetail = !state.trimmedDetail.isEmpty
        if hasDetail,
           !state.isSelected(.other),
           state.selectedReasons.count < WithdrawalReasonType.maxSelection {
            state.selectedReasons.append(.other)
        }
    }

    private func validateAndConfirm() {
        guard !state.selectedReasons.isEmpty || !state.trimmedDetail.isEmpty else {
            state.message = "탈퇴 사유를 선택해 주세요."
            return
        }
        // 기타 내용을 입력하면 서버가 OTHER를 자동 포함하므로 그것까지 3개 안이어야 함
        let total = Set(state.selectedReasons + (state.trimmedDetail.isEmpty ? [] : [.other])).count
        guard total <= WithdrawalReasonType.maxSelection else {
            state.message = "기타 내용을 작성하면 '기타'가 함께 선택돼요.\n탈퇴 사유를 \(WithdrawalReasonType.maxSelection)개 이내로 선택해 주세요."
            return
        }
        state.showConfirmAlert = true
    }

    /// 서버 실패 사유가 비어 있으면 기본 문구
    private static func failureMessage(_ serverMessage: String?) -> String {
        let trimmed = serverMessage?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "회원 탈퇴에 실패했습니다.\n잠시 후 다시 시도해 주세요." : trimmed
    }

    /// A11 확인: 회원 정보 삭제 및 팝업 종료 → 로그인 화면 노출
    private func withdraw() {
        guard !state.isSubmitting else { return }
        state.showConfirmAlert = false

        let detail = state.trimmedDetail
        var reasons = state.selectedReasons
        if !detail.isEmpty && !reasons.contains(.other) {
            reasons.append(.other)
        }
        let body = WithdrawalRequestDto(
            reasonTypes: reasons,
            reasonDetail: detail.isEmpty ? nil : detail
        )

        state.isSubmitting = true
        Task {
            defer { state.isSubmitting = false }
            do {
                let response = try await APIService.shared.withdraw(body: body)
                // 200이어도 탈퇴 처리가 안 됐다고 내려오면 실패로 보고 서버 메시지 노출
                guard response.withdrawn != false else {
                    print("⚠️ [Withdrawal] 회원 탈퇴 미처리: \(response.message ?? "")")
                    state.message = Self.failureMessage(response.message)
                    return
                }
                print("✅ [Withdrawal] 회원 탈퇴 완료: \(response.message ?? "")")
                // 서버에서 토큰을 폐기했으므로 기기 토큰도 삭제
                AuthManager.shared.logout()
                onWithdrawalCompleted()
            } catch APIError.serverError(let statusCode, let errorCode, let message) {
                // status: "fail" → 서버가 errorMessage에 담아준 탈퇴 실패 사유를 팝업으로 노출
                print("⚠️ [Withdrawal] 회원 탈퇴 실패(\(statusCode), \(errorCode ?? "-")): \(message)")
                state.message = Self.failureMessage(message)
            } catch {
                print("❌ [Withdrawal] 회원 탈퇴 실패: \(error)")
                state.message = Self.failureMessage(nil)
            }
        }
    }
}

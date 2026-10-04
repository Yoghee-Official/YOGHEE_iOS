//
//  AttendanceCheckContainer.swift
//  YOGHEE
//
//  마이페이지(지도자) "오늘의 수업" 출석체크 바텀시트 (피그마 node-id 3-13279)
//

import Foundation

// MARK: - Intent
enum AttendanceCheckIntent {
    case load
    case toggleAttendance(reservationId: String)
    case checkAllAttendance
    case requestCancelReservation(reservationId: String)
    case confirmCancelReservation
    case dismissCancelAlert
}

// MARK: - State
struct AttendanceCheckState: Equatable {
    var session: LeaderSessionDTO?
    var members: [LeaderSessionMemberDTO] = []
    var isLoading: Bool = false
    var errorMessage: String?
    /// 취소 확인 얼럿 대상 예약 ID (nil이면 얼럿 미노출)
    var reservationIdPendingCancel: String?
}

@MainActor
class AttendanceCheckContainer: ObservableObject {
    @Published private(set) var state = AttendanceCheckState()

    private let sessionId: String?

    init(sessionId: String?) {
        self.sessionId = sessionId
    }

    func handleIntent(_ intent: AttendanceCheckIntent) {
        switch intent {
        case .load:
            loadMembers()
        case .toggleAttendance(let reservationId):
            toggleAttendance(reservationId: reservationId)
        case .checkAllAttendance:
            checkAllAttendance()
        case .requestCancelReservation(let reservationId):
            state.reservationIdPendingCancel = reservationId
        case .confirmCancelReservation:
            confirmCancelReservation()
        case .dismissCancelAlert:
            state.reservationIdPendingCancel = nil
        }
    }

    // MARK: - Private

    private func loadMembers() {
        state.isLoading = true
        state.errorMessage = nil

        guard let sessionId else {
            state.errorMessage = "세션 정보를 찾을 수 없습니다."
            state.isLoading = false
            return
        }

        Task { @MainActor in
            do {
                let response = try await APIService.shared.getSessionMembers(sessionId: sessionId)
                state.session = response.session
                state.members = response.members
                state.isLoading = false
            } catch {
                state.errorMessage = (error as? APIError)?.errorDescription ?? "출석 정보를 불러오지 못했습니다."
                state.isLoading = false
            }
        }
    }

    /// 영역 클릭 시 출석 완료 처리, 재 클릭 시 출석 취소(미출석) 처리
    private func toggleAttendance(reservationId: String) {
        guard let sessionId,
              let index = state.members.firstIndex(where: { $0.reservationId == reservationId }),
              state.members[index].attendanceStatus != .CANCELLED else { return }

        let previousStatus = state.members[index].attendanceStatus
        let newStatus: AttendanceStatus = previousStatus == .ATTENDED ? .NOT_ATTENDED : .ATTENDED

        // 낙관적 업데이트
        state.members[index].attendanceStatus = newStatus

        Task { @MainActor in
            do {
                try await APIService.shared.updateAttendance(sessionId: sessionId, reservationIds: [reservationId], status: newStatus)
            } catch {
                // 실패 시 롤백
                if let index = state.members.firstIndex(where: { $0.reservationId == reservationId }) {
                    state.members[index].attendanceStatus = previousStatus
                }
                state.errorMessage = (error as? APIError)?.errorDescription ?? "출석 처리에 실패했습니다."
            }
        }
    }

    /// 한 번에 출석: 아직 출석 처리되지 않은(취소 제외) 모든 예약을 출석 완료로 변경
    private func checkAllAttendance() {
        guard let sessionId else { return }

        let targetIds = state.members
            .filter { $0.attendanceStatus != .ATTENDED && $0.attendanceStatus != .CANCELLED }
            .map { $0.reservationId }

        guard !targetIds.isEmpty else { return }

        let previousStatuses = state.members.map { $0.attendanceStatus }

        for index in state.members.indices where targetIds.contains(state.members[index].reservationId) {
            state.members[index].attendanceStatus = .ATTENDED
        }

        Task { @MainActor in
            do {
                try await APIService.shared.updateAttendance(sessionId: sessionId, reservationIds: targetIds, status: .ATTENDED)
            } catch {
                for (index, status) in previousStatuses.enumerated() where index < state.members.count {
                    state.members[index].attendanceStatus = status
                }
                state.errorMessage = (error as? APIError)?.errorDescription ?? "출석 처리에 실패했습니다."
            }
        }
    }

    private func confirmCancelReservation() {
        guard let reservationId = state.reservationIdPendingCancel else { return }
        state.reservationIdPendingCancel = nil

        Task { @MainActor in
            do {
                try await APIService.shared.cancelLeaderReservation(reservationId: reservationId)
                state.members.removeAll { $0.reservationId == reservationId }
            } catch {
                state.errorMessage = (error as? APIError)?.errorDescription ?? "예약 취소에 실패했습니다."
            }
        }
    }
}

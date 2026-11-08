//
//  ReservationHistoryContainer.swift
//  YOGHEE
//
//  요기니 마이페이지 > 예약한 수련 미리보기 "목록 더보기" > 내역 보기 (RC_MO_1)
//

import SwiftUI

// MARK: - Intent
enum ReservationHistoryIntent {
    case load
    case selectTab(ReservationHistoryTab)
    case toggleSortPopup
    case changeSort(ReservationHistorySort)
    /// 하루수련 "예약 및 결제 취소하기" → 확인 얼럿(Alert_13) 노출
    case requestCancel(ReservationDTO)
    case dismissCancel
    /// Alert_13 "확인" → 취소 요청(CL_MO_1) 화면 이동
    case confirmCancel
}

// MARK: - State
struct ReservationHistoryState: Equatable {
    var selectedTab: ReservationHistoryTab = .reserved
    /// nil이면 "정렬순"(서버 기본: 수업 시작 시각 순)
    var sort: ReservationHistorySort? = nil
    var showSortPopup: Bool = false

    /// 2c: 예약 완료 + 취소 완료 내역
    var reservedItems: [ReservationDTO] = []
    /// 2d: 완료된 내역
    var expiredItems: [ReservationDTO] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var pendingCancel: ReservationDTO? = nil

    var currentItems: [ReservationDTO] {
        switch selectedTab {
        case .reserved: return reservedItems
        case .expired: return expiredItems
        }
    }
}

// MARK: - Container
@MainActor
class ReservationHistoryContainer: ObservableObject {
    @Published private(set) var state = ReservationHistoryState()
    /// 정렬을 연달아 바꿀 때 이전 요청 응답이 늦게 도착해 최신 결과를 덮어쓰지 않도록 이전 요청을 취소
    private var loadTask: Task<Void, Never>?

    func handleIntent(_ intent: ReservationHistoryIntent) {
        switch intent {
        case .load:
            load()
        case .selectTab(let tab):
            state.selectedTab = tab
            state.showSortPopup = false
        case .toggleSortPopup:
            state.showSortPopup.toggle()
        case .changeSort(let sort):
            state.showSortPopup = false
            guard state.sort != sort else { return }
            state.sort = sort
            // 적용 시 리로드
            load()
        case .requestCancel(let reservation):
            state.pendingCancel = reservation
        case .dismissCancel:
            state.pendingCancel = nil
        case .confirmCancel:
            guard let reservation = state.pendingCancel else { return }
            state.pendingCancel = nil
            // 취소 사유 선택·환불정보 확인 후 실제 취소(POST /api/my/reservations/{reservationId}/cancel)는 CL_MO_1에서 진행
            print("💳 [내역 보기] 예약 및 결제 취소 확인 - TODO: 취소 요청(CL_MO_1) 이동 (reservationId: \(reservation.reservationId))")
        }
    }

    private func load() {
        loadTask?.cancel()
        state.isLoading = true
        state.errorMessage = nil
        let sort = state.sort

        loadTask = Task { @MainActor in
            do {
                // status 없이 전체를 받아 탭별로 나눈다 (예약 항목 탭에 UPCOMING + CANCELLED가 함께 노출되므로)
                let reservations = try await APIService.shared.getMyReservations(sort: sort?.rawValue)
                guard !Task.isCancelled else { return }
                state.reservedItems = reservations.filter { !$0.isCompleted }
                state.expiredItems = reservations.filter { $0.isCompleted }
                state.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                log("❌ 내역 보기 로딩 에러: \(error)")
                state.errorMessage = error.localizedDescription
                state.isLoading = false
            }
        }
    }

    private func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}

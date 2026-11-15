//
//  OpenedClassListContainer.swift
//  YOGHEE
//
//  지도자 마이페이지 > 수련 미리보기 "목록 더보기" > 개설한 수련 목록 (OC_MO_1)
//

import SwiftUI

// MARK: - Intent
enum OpenedClassListIntent {
    case load
    /// 2a: 카테고리 필터 팝업
    case showCategoryFilter(Bool)
    case applyCategoryFilter(Set<String>)
    /// 2b: 전체 / 하루수련 / 정규수련
    case selectTab(OpenedClassTab)
    /// 2c: 종료된 수련 숨기기
    case toggleHideEnded
    /// 3b: 공지사항 보내기
    case sendNotice(LeaderClassDTO)
    /// 3c: 더보기 (nil이면 닫기)
    case toggleMoreMenu(String?)
    case edit(LeaderClassDTO)
    case copy(LeaderClassDTO)
    /// 삭제 → 확인 얼럿(Alert_20) 노출
    case requestDelete(LeaderClassDTO)
    case dismissDelete
    case confirmDelete
    case dismissAlert
}

// MARK: - State
struct OpenedClassListState: Equatable {
    var classes: [LeaderClassDTO] = []
    /// 필터가 적용된 노출 목록 (필터 변경·로딩 시에만 다시 계산)
    var visibleClasses: [LeaderClassDTO] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var selectedTab: OpenedClassTab = .all
    var hideEndedClasses: Bool = true
    /// 2a: 선택한 카테고리 코드 (소문자, YogaCodeHardcoded 기준)
    var selectedCategoryCodes: Set<String> = []
    var showCategoryFilter: Bool = false

    /// 3c: 더보기 메뉴가 열린 수련
    var moreMenuClassId: String? = nil
    var pendingDelete: LeaderClassDTO? = nil
    var isDeleting: Bool = false
    /// 삭제 실패 등 안내 팝업 문구
    var alertMessage: String? = nil
}

// MARK: - Container
@MainActor
class OpenedClassListContainer: ObservableObject {
    @Published private(set) var state = OpenedClassListState()

    func handleIntent(_ intent: OpenedClassListIntent) {
        switch intent {
        case .load:
            load()
        case .showCategoryFilter(let isPresented):
            state.moreMenuClassId = nil
            state.showCategoryFilter = isPresented
        case .applyCategoryFilter(let codes):
            state.selectedCategoryCodes = codes
            state.showCategoryFilter = false
            applyFilters()
        case .selectTab(let tab):
            state.moreMenuClassId = nil
            state.selectedTab = tab
            applyFilters()
        case .toggleHideEnded:
            state.moreMenuClassId = nil
            state.hideEndedClasses.toggle()
            applyFilters()
        case .sendNotice(let item):
            state.moreMenuClassId = nil
            print("📢 [개설한 수련 목록] 공지사항 보내기 클릭 - TODO: 공지 팝업 (classId: \(item.classId))")
        case .toggleMoreMenu(let classId):
            state.moreMenuClassId = state.moreMenuClassId == classId ? nil : classId
        case .edit(let item):
            state.moreMenuClassId = nil
            print("✏️ [개설한 수련 목록] 수정 클릭 - TODO: 수련 수정 화면 이동 (classId: \(item.classId))")
        case .copy(let item):
            state.moreMenuClassId = nil
            print("📄 [개설한 수련 목록] 복사 클릭 - TODO: 수련 정보 복사 후 수련 등록 화면 이동 (classId: \(item.classId))")
        case .requestDelete(let item):
            state.moreMenuClassId = nil
            state.pendingDelete = item
        case .dismissDelete:
            state.pendingDelete = nil
        case .confirmDelete:
            deletePendingClass()
        case .dismissAlert:
            state.alertMessage = nil
        }
    }

    private func load() {
        state.isLoading = true
        state.errorMessage = nil

        Task { @MainActor in
            do {
                state.classes = try await APIService.shared.getLeaderClasses()
                applyFilters()
                state.isLoading = false
            } catch {
                log("❌ 개설한 수련 목록 로딩 에러: \(error)")
                state.errorMessage = error.localizedDescription
                state.isLoading = false
            }
        }
    }

    /// 2a 카테고리 / 2b 수련 유형 / 2c 종료된 수련 숨기기를 함께 적용
    private func applyFilters() {
        let categoryCodes = state.selectedCategoryCodes
        state.visibleClasses = state.classes.filter { item in
            switch state.selectedTab {
            case .all: break
            case .oneDay: if item.isRegular { return false }
            case .regular: if !item.isRegular { return false }
            }
            if state.hideEndedClasses && item.isEnded { return false }
            // 선택한 카테고리 중 하나라도 포함된 수련 노출
            if !categoryCodes.isEmpty && item.lowercasedCategoryCodes.isDisjoint(with: categoryCodes) { return false }
            return true
        }
    }

    private func deletePendingClass() {
        guard let item = state.pendingDelete, !state.isDeleting else { return }
        state.pendingDelete = nil
        state.isDeleting = true

        Task { @MainActor in
            do {
                try await APIService.shared.deleteLeaderClass(classId: item.classId)
                state.isDeleting = false
                state.classes.removeAll { $0.classId == item.classId }
                applyFilters()
            } catch {
                log("❌ 개설한 수련 삭제 에러: \(error)")
                state.isDeleting = false
                // 409: 예약·결제 이력이 있어 삭제 불가 등 서버 메시지를 그대로 안내
                state.alertMessage = error.localizedDescription
            }
        }
    }

    private func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}

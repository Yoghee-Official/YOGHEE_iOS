//
//  ExploreTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import Foundation

// MARK: - Intent

enum ExploreTabIntent {
    /// 지도 카메라 정지 — 최초 진입·재검색 bbox 확보용 (isUserGesture: 사용자의 스크롤/줌 여부)
    case mapCameraIdle(bbox: MapBoundingBox, isUserGesture: Bool)
    /// cameraCommand 이동 완료
    case cameraCommandFinished(bbox: MapBoundingBox)
    /// 위치 권한 확정 — nil이면 권한 미동의(서울시청 중심 유지)
    case locationResolved(coordinate: MapCoordinate?)
    /// 3c 현위치 버튼
    case moveToCurrentLocation(coordinate: MapCoordinate)
    /// 1c 검색 버튼
    case submitKeyword(String)
    /// 2b/2c 하루수련 보기 / 정규수련 모아보기
    case selectClassType(ExploreClassType)
    /// 2d 오늘 예약
    case toggleTodayAvailable
    /// 2a 필터 레이어 적용 / 닫기(초기화)
    case applyFilter(ExploreSearchFilter)
    /// 3d 해당 위치 재검색
    case researchCurrentArea
    /// 3b 위치 핀 탭 — nil이면 선택 해제
    case selectClass(id: String?)
    /// 4a 찜 버튼
    case toggleFavorite(classId: String)
    case dismissToast
}

// MARK: - Camera Command

/// 지도 카메라 이동 명령 — id로 동일 좌표 재요청도 구분
struct ExploreCameraCommand: Equatable {
    let id = UUID()
    let coordinate: MapCoordinate
    let zoomLevel: Int
}

// MARK: - State

struct ExploreTabState: Equatable {
    /// 3a 현재 위치 반영 1km 기준 (Zoom level 15)
    static let defaultZoomLevel = 15
    /// 3b 핀 선택 시 500m 반경으로 확대
    static let selectedZoomLevel = 16

    var classType: ExploreClassType = .oneDay   // default 하루수련(원데이) 모아보기
    var isTodayAvailable: Bool = false
    var filter = ExploreSearchFilter()
    /// 검색 결과 화면에 유지되는 검색어
    var keyword: String = ""

    var classes: [ClassMapMarkerDTO] = []
    /// 결과를 조회한 수련 타입 — 4a 정규/하루 구분값 표시용
    var resultClassType: ExploreClassType = .oneDay
    var selectedClassId: String?
    /// 4a 주소 1줄 (시·구·동) — 핀 선택 시 상세 API로 조회
    var selectedClassAddress: String?

    var cameraCommand: ExploreCameraCommand?
    var currentBbox: MapBoundingBox?
    /// 3d 재검색 버튼 노출 여부
    var showsResearchButton: Bool = false
    var toastMessage: String?
    var isLoading: Bool = false
    var errorMessage: String?

    var selectedClass: ClassMapMarkerDTO? {
        guard let selectedClassId else { return nil }
        return classes.first { $0.classId == selectedClassId }
    }
}

// MARK: - Container

@MainActor
class ExploreTabContainer: ObservableObject {
    @Published private(set) var state = ExploreTabState()

    /// 최초 진입 검색 대기 — 위치 확정 + 지도 bbox 확보 후 1회 실행
    private var needsInitialSearch = true
    private var isLocationResolved = false
    /// 현재 위치로 카메라 이동 중 — 이동 완료 bbox로 최초 검색
    private var isWaitingInitialCamera = false
    /// 최초 검색 이후부터 사용자 스크롤/줌 시 재검색 버튼 노출
    private var hasSearched = false

    private var searchTask: Task<Void, Never>?
    private var detailTask: Task<Void, Never>?

    func handleIntent(_ intent: ExploreTabIntent) {
        switch intent {
        case .mapCameraIdle(let bbox, let isUserGesture):
            state.currentBbox = bbox
            if isUserGesture && hasSearched { state.showsResearchButton = true }
            runInitialSearchIfReady()

        case .cameraCommandFinished(let bbox):
            state.currentBbox = bbox
            isWaitingInitialCamera = false
            runInitialSearchIfReady()

        case .locationResolved(let coordinate):
            guard !isLocationResolved else { return }
            isLocationResolved = true
            if let coordinate {
                isWaitingInitialCamera = true
                state.cameraCommand = ExploreCameraCommand(coordinate: coordinate, zoomLevel: ExploreTabState.defaultZoomLevel)
            }
            runInitialSearchIfReady()

        case .moveToCurrentLocation(let coordinate):
            state.cameraCommand = ExploreCameraCommand(coordinate: coordinate, zoomLevel: ExploreTabState.defaultZoomLevel)
            if hasSearched { state.showsResearchButton = true }

        case .submitKeyword(let keyword):
            let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }   // 미입력 시 반응 없음
            state.keyword = trimmed
            search(movesCameraToFirstResult: true)

        case .selectClassType(let type):
            guard state.classType != type else { return }   // 중복 선택 불가 — 선택된 버튼 재탭 무시
            state.classType = type
            search()

        case .toggleTodayAvailable:
            state.isTodayAvailable.toggle()
            search()

        case .applyFilter(let filter):
            guard state.filter != filter else { return }
            state.filter = filter
            search()

        case .researchCurrentArea:
            search()

        case .selectClass(let id):
            selectClass(id: id)

        case .toggleFavorite(let classId):
            toggleFavorite(classId: classId)

        case .dismissToast:
            state.toastMessage = nil
        }
    }

    // MARK: - 최초 진입 검색

    private func runInitialSearchIfReady() {
        guard needsInitialSearch, isLocationResolved, !isWaitingInitialCamera, state.currentBbox != nil else { return }
        needsInitialSearch = false
        search(showsEmptyToast: false)
    }

    // MARK: - 검색

    private func search(movesCameraToFirstResult: Bool = false, showsEmptyToast: Bool = true) {
        guard let bbox = state.currentBbox else { return }

        let query = ClassMapSearchQuery(
            type: state.classType,
            bbox: bbox,
            keyword: state.keyword.isEmpty ? nil : state.keyword,
            filter: state.filter,
            todayAvailable: state.isTodayAvailable
        )

        hasSearched = true
        state.showsResearchButton = false
        state.isLoading = true
        state.errorMessage = nil

        searchTask?.cancel()
        searchTask = Task {
            do {
                let classes = try await APIService.shared.searchClassMap(query: query)
                guard !Task.isCancelled else { return }
                self.state.classes = classes
                self.state.resultClassType = query.type
                self.selectClass(id: nil)               // 새 검색 시 핀 선택 초기화
                self.state.isLoading = false

                if classes.isEmpty {
                    if showsEmptyToast { self.state.toastMessage = query.type.emptyResultMessage }
                } else if movesCameraToFirstResult, let first = classes.first {
                    // 검색어 검색 시 응답 0번째 수련 위치로 이동
                    self.state.cameraCommand = ExploreCameraCommand(
                        coordinate: MapCoordinate(latitude: first.latitude, longitude: first.longitude),
                        zoomLevel: ExploreTabState.defaultZoomLevel
                    )
                }
                print("✅ 지도 수련 로드 완료: \(classes.count)개 (\(query.type.label))")
            } catch {
                guard !Task.isCancelled else { return }
                self.state.errorMessage = error.localizedDescription
                self.state.isLoading = false
                print("❌ 지도 수련 로드 실패: \(error)")
            }
        }
    }

    // MARK: - 핀 선택

    private func selectClass(id: String?) {
        detailTask?.cancel()
        state.selectedClassId = id
        state.selectedClassAddress = nil

        guard let id, let selected = state.selectedClass else { return }

        state.cameraCommand = ExploreCameraCommand(
            coordinate: MapCoordinate(latitude: selected.latitude, longitude: selected.longitude),
            zoomLevel: ExploreTabState.selectedZoomLevel
        )

        // 지도 API에 주소가 없어 상세 API로 시·구·동 조회
        detailTask = Task {
            do {
                let detail = try await APIService.shared.getClassDetail(classId: id).data
                guard !Task.isCancelled, self.state.selectedClassId == id else { return }
                let center = detail.center
                let address = [center?.depth1, center?.depth2, center?.depth3]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
                self.state.selectedClassAddress = address.isEmpty ? nil : address
            } catch {
                print("❌ 수련 주소 조회 실패: \(error)")
            }
        }
    }

    // MARK: - 찜

    private func toggleFavorite(classId: String) {
        updateFavorite(classId: classId) { !($0 ?? false) }

        Task {
            do {
                try await APIService.shared.toggleClassFavorite(classId: classId)
            } catch {
                // 실패 시 원복
                self.updateFavorite(classId: classId) { !($0 ?? false) }
                print("❌ 수련 찜 처리 실패: \(error)")
            }
        }
    }

    private func updateFavorite(classId: String, transform: (Bool?) -> Bool) {
        state.classes = state.classes.map { item in
            guard item.classId == classId else { return item }
            var updated = item
            updated.isFavorite = transform(item.isFavorite)
            return updated
        }
    }
}

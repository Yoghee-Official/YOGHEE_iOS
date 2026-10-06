//
//  ExploreLocationManager.swift
//  YOGHEE
//

import CoreLocation

/// 검색 탭 위치 권한 / 현재 위치 관리
/// - 최초 진입 시 위치 허용 얼럿(access_1) 노출
/// - 위치 권한 동의 시 GPS 기준 현재 위치, 미동의 시 서울시청 중심
@MainActor
final class ExploreLocationManager: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var currentCoordinate: MapCoordinate?

    private let manager = CLLocationManager()

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    /// 권한 요청 결과가 확정됐는지 (notDetermined가 아니면 확정)
    var isAuthorizationDetermined: Bool {
        authorizationStatus != .notDetermined
    }

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    /// 최초 진입 시 호출 — 미결정이면 권한 얼럿, 허용 상태면 위치 갱신
    func requestAuthorizationIfNeeded() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    /// 3c 현위치 버튼 — 최신 위치 재요청
    func refreshLocation() {
        guard isAuthorized else { return }
        manager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension ExploreLocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if self.isAuthorized {
                self.manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = MapCoordinate(latitude: location.coordinate.latitude,
                                       longitude: location.coordinate.longitude)
        Task { @MainActor in
            self.currentCoordinate = coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 위치 조회 실패: \(error)")
    }
}

//
//  ExploreModels.swift
//  YOGHEE
//

import Foundation

// MARK: - 지도 영역 Bounding Box

struct MapBoundingBox: Equatable {
    let swLat: Double
    let swLng: Double
    let neLat: Double
    let neLng: Double
}

// MARK: - 지도 좌표

struct MapCoordinate: Equatable {
    let latitude: Double
    let longitude: Double

    /// 위치 권한 미동의 시 기본 중심 좌표 (서울특별시 중구 서울시청)
    static let seoulCityHall = MapCoordinate(latitude: 37.5663, longitude: 126.9779)
}

// MARK: - 검색 수련 타입 (2b 하루수련 보기 / 2c 정규수련 모아보기 — 중복 선택 불가)

enum ExploreClassType: Equatable {
    case oneDay
    case regular

    /// 1b 검색바 placeholder
    var placeholder: String {
        switch self {
        case .oneDay:  return "수련명을 검색해보세요."
        case .regular: return "요가원명을 검색해보세요."
        }
    }

    /// 3b 검색 결과 없음 토스트
    var emptyResultMessage: String {
        switch self {
        case .oneDay:  return "검색결과가 없습니다. 요가원명으로 검색해보세요."
        case .regular: return "검색결과가 없습니다. 수련명으로 검색해보세요."
        }
    }

    /// 4a 카드 정규/하루 구분값
    var label: String {
        switch self {
        case .oneDay:  return "하루수련"
        case .regular: return "정규수련"
        }
    }
}

// MARK: - 상세 필터 (2a 필터 레이어)

struct ExploreSearchFilter: Equatable {
    /// 시간 슬라이더 기본값 (9시 ~ 17시)
    static let defaultStartHour = 9
    static let defaultEndHour   = 17

    var trainingTypeCodes: Set<String> = []   // 전문 수련 유형
    var categoryCodes: Set<String> = []       // 수련 태그
    var targetCodes: Set<String> = []         // 이용 대상
    var dates: Set<String> = []               // yyyy-MM-dd
    var startHour: Int = defaultStartHour
    var endHour: Int = defaultEndHour
    var amenityCodes: Set<String> = []        // 수련원 편의시설

    /// 시간은 기본값에서 변경한 경우에만 유효값으로 취급
    var isTimeChanged: Bool {
        startHour != Self.defaultStartHour || endHour != Self.defaultEndHour
    }

    /// 2a 필터 버튼 활성화 기준 — 유효값이 하나라도 있는지
    var hasValidValue: Bool {
        !trainingTypeCodes.isEmpty || !categoryCodes.isEmpty || !targetCodes.isEmpty
            || !dates.isEmpty || isTimeChanged || !amenityCodes.isEmpty
    }

    /// 서버 categoryCodes(OR)로 전달 — 수련 유형·태그·이용 대상을 합쳐서 전송
    var allCategoryCodes: [String] {
        (trainingTypeCodes.union(categoryCodes).union(targetCodes)).sorted()
    }
}

// MARK: - 지도 수련 검색 Query

struct ClassMapSearchQuery: Equatable {
    let type: ExploreClassType
    let bbox: MapBoundingBox
    let keyword: String?
    let filter: ExploreSearchFilter
    let todayAvailable: Bool
}

// MARK: - 지도 수련 검색 Response (GET /api/center/search/one-day, /regular)

struct ClassMapMarkerResponse: Codable {
    let code: Int
    let status: String
    let data: [ClassMapMarkerDTO]
}

/// 지도 핀 + 미리보기 카드용 최소 응답
/// - name: 하루수련은 수련명, 정규수련은 요가원명
struct ClassMapMarkerDTO: Codable, Equatable {
    let classId: String
    let name: String
    let thumbnail: String?
    let avgRating: Double?
    let reviewCount: Int?
    var isFavorite: Bool?
    let latitude: Double
    let longitude: Double
}

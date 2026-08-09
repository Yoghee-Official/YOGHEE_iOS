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

// MARK: - 지도 영역 수련 검색 Response

struct ClassMapSearchResponse: Codable {
    let code: Int
    let status: String
    let data: ClassMapSearchData
}

// MARK: - 지도 영역 수련 검색 Data
// API 변경: data가 배열 → 객체로 변경 (resultState / results / recommendations)

struct ClassMapSearchData: Codable {
    let resultState: ResultState
    let results: [ClassMapSearchDTO]
    let recommendations: [ClassMapSearchDTO]  // 나중에 쓸 예정 — 모델링만
}

// MARK: - 결과 상태
// IN_BOUNDS: 현재 지도 안에 결과 있음 → 카메라 유지
// OUT_OF_BOUNDS: 결과가 지도 밖 → results[0] 좌표로 카메라 이동
// EMPTY: 결과 없음 → 카메라 유지, 빈 화면 표시

enum ResultState: String, Codable, Equatable {
    case inBounds    = "IN_BOUNDS"
    case outOfBounds = "OUT_OF_BOUNDS"
    case empty       = "EMPTY"
}

// MARK: - 지도 영역 수련 검색 DTO

struct ClassMapSearchDTO: Codable, Equatable {
    let centerId: String
    let centerName: String
    let address: String?
    let latitude: Double
    let longitude: Double
    let thumbnail: String?
    let classId: String
    let className: String
    let type: String
    let typeLabel: String
    let classThumbnail: String?
    let price: Int?
    let avgRating: Double?
    let reviewCount: Int?
    let isFavorite: Bool?
    let schedules: [ClassScheduleDTO]?
}

// MARK: - 스케줄 슬롯 DTO

struct ClassScheduleDTO: Codable, Equatable {
    let date: String?       // yyyy-MM-dd (하루수련)
    let dayOfWeek: Int?     // 1=월 ~ 7=일 (정규수련)
    let startTime: String?  // HH:mm
    let endTime: String?    // HH:mm
}

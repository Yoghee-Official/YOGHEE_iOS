//
//  ExploreModels.swift
//  YOGHEE
//

import Foundation

// MARK: - 지도 영역 Bounding Box

struct MapBoundingBox {
    let swLat: Double
    let swLng: Double
    let neLat: Double
    let neLng: Double
}

// MARK: - 지도 영역 수련 검색 Response

struct ClassMapSearchResponse: Codable {
    let code: Int
    let status: String
    let data: [ClassMapSearchDTO]
}

// MARK: - 지도 영역 수련 검색 DTO

struct ClassMapSearchDTO: Codable, Equatable {
    let centerId: String
    let centerName: String
    let address: String
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
}

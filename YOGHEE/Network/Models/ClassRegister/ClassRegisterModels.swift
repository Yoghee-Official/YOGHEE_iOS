//
//  ClassRegisterModels.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/27/26.
//

import Foundation

// MARK: - Code List API (GET /api/main/code)

struct CodeListResponse: Codable {
    let code: Int
    let status: String
    let data: CodeListDto
}

struct CodeListDto: Codable {
    /// 카테고리 목록 (type별 그룹핑)
    let categories: CategoryCodeListDTO
    /// 특징 목록 (수련 장점 - 어디에 도움되는 수업인지)
    let features: [CodeInfoDTO]
    /// 편의시설 목록 (type별 그룹핑)
    let amenities: AmenityCodeListDTO
}

struct CategoryCodeListDTO: Codable {
    let category: [CodeInfoDTO]
    let type: [CodeInfoDTO]
    let target: [CodeInfoDTO]
}

struct AmenityCodeListDTO: Codable {
    let amenity: [CodeInfoDTO]
    let facility: [CodeInfoDTO]
}

struct CodeInfoDTO: Codable, Identifiable, Hashable {
    let id: String
    let name: String
}

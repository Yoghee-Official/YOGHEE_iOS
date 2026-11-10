//
//  OpenedClassModels.swift
//  YOGHEE
//
//  지도자 개설한 수련 목록(OC_MO_1) 화면 데이터 - GET /api/leader/classes (LeaderClassListItemDto)
//

import Foundation

// MARK: - 2b: 전체 / 하루수련 / 정규수련 필터
enum OpenedClassTab: CaseIterable {
    case all
    case oneDay
    case regular

    var title: String {
        switch self {
        case .all: return "전체"
        case .oneDay: return "하루수련"
        case .regular: return "정규수련"
        }
    }
}

// MARK: - 개설한 수련 목록 응답
/// 스웨거상으로는 배열을 바로 반환하지만, 실제 응답은 다른 API와 동일하게 {code, status, data}로 래핑돼 내려옴
struct LeaderClassListResponse: Codable {
    let code: Int
    let status: String
    let data: [LeaderClassDTO]
}

// MARK: - 개설한 수련 (LeaderClassListItemDto)
struct LeaderClassDTO: Codable, Identifiable, Equatable {
    let classId: String
    /// O: 하루수련, R: 정규수련
    let type: String?
    let name: String?
    let thumbnail: String?
    let price: Int?
    let originalPrice: Int?
    let discountRate: Int?
    let centerId: String?
    /// 정규수련 수련원명. 하루수련은 null
    let centerName: String?
    /// 정규수련 수련원 주소. 하루수련은 null
    let address: String?
    /// 카테고리 코드 목록 (2a 카테고리 필터용)
    let categoryCodes: [String]?
    let createdAt: String?
    /// READ_ONLY(정규수련) / UPCOMING / COMPLETED / CANCELLED / NO_SESSION
    let status: String?
    let sessionCount: Int?
    let upcomingSessionCount: Int?
    let reservationCount: Int?
    let nextSessionAt: String?

    var id: String { classId }

    var isRegular: Bool { type == "R" }

    /// 2c: 종료된 수련 — 하루수련만 해당 (정규수련은 항상 노출)
    var isEnded: Bool { !isRegular && status == "COMPLETED" }

    /// 카테고리 필터 비교용 (서버는 대문자, 앱 코드표는 소문자라 소문자로 맞춤)
    var lowercasedCategoryCodes: Set<String> {
        Set((categoryCodes ?? []).map { $0.lowercased() })
    }

    /// 3a: 하루수련 수련명 / 정규수련 수련원명
    var title: String {
        isRegular ? (centerName ?? name ?? "") : (name ?? "")
    }

    /// 3a: 하루수련 지도자명 / 정규수련 주소(동까지)
    var subtitle: String? {
        // TODO: 서버 필드 추가 예정 - LeaderClassListItemDto에 지도자명 필드가 추가되면 "OOO 지도자"로 교체
        isRegular ? Self.addressUntilDong(address) : "TODO: 서버 필드 추가 예정"
    }

    /// "서울 강남구 역삼동 123-4" → "서울 강남구 역삼동"
    /// 동·읍·면이 없는 도로명 주소는 시·구·도로명까지만 노출
    private static func addressUntilDong(_ address: String?) -> String? {
        guard let address, !address.isEmpty else { return nil }
        let words = address.split(separator: " ")
        if let index = words.firstIndex(where: { $0.hasSuffix("동") || $0.hasSuffix("읍") || $0.hasSuffix("면") }) {
            return words[...index].joined(separator: " ")
        }
        return words.prefix(3).joined(separator: " ")
    }
}

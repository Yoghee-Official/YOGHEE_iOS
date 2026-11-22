//
//  FaqModels.swift
//  YOGHEE
//
//  FAQ(CS_MO_1) 화면 데이터
//  - GET /api/faqs/categories : 카테고리 칩 목록 (배열 순서 = 탭 순서, 첫 항목이 기본 선택)
//  - GET /api/faqs?target=&category= : 대상·카테고리별 질문/답변 목록 (관리자가 정한 순서)
//

import Foundation

// MARK: - 노출 대상

/// FAQ 노출 대상. 요기니 마이페이지(YMP_MO_1) 진입 시 YOGINI, 지도자 마이페이지(TMP_MO_1) 진입 시 LEADER
enum FaqTarget: String, Codable, Hashable {
    case yogini = "YOGINI"
    case leader = "LEADER"

    init(role: UserRole) {
        switch role {
        case .yogini: self = .yogini
        case .instructor: self = .leader
        }
    }
}

// MARK: - 응답 래퍼

/// 스웨거 스키마에는 배열만 표기돼 있으나, 실제 응답은 {code, status, data}로 감싸서 내려온다.
struct FaqListResponse<T: Codable>: Codable {
    let code: Int
    let status: String
    let data: [T]
}

// MARK: - DTO

/// 3a 카테고리 칩
struct FaqCategoryDto: Codable, Equatable, Hashable {
    /// 카테고리 코드 (RESERVATION / TICKET_PAYMENT / ACCOUNT / CENTER) — GET /api/faqs?category= 로 전달
    let code: String
    /// 칩 표시명 (예: 예약/취소)
    let label: String
}

/// 3b 질문 & 답변
struct FaqDto: Codable, Equatable, Identifiable {
    let faqId: String
    let target: String?
    let category: String?
    let question: String
    let answer: String

    var id: String { faqId }
}

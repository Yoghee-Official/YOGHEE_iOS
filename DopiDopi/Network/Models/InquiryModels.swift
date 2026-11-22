//
//  InquiryModels.swift
//  YOGHEE
//
//  나의 문의(CS_MO_2) 화면 데이터 - 요기니 전용
//  - GET  /api/inquiries/categories : 문의 유형 드롭다운 선택지
//  - POST /api/inquiries            : 1:1 문의 등록
//  - GET  /api/inquiries?page=&size= : 나의 문의함 (최신순, Page<InquiryDto>)
//

import Foundation

// MARK: - 문의 유형

/// 4a 문의 유형 드롭다운 선택지
struct InquiryCategoryDto: Codable, Equatable, Hashable {
    /// 문의 유형 코드 (RESERVATION / PAYMENT / ACCOUNT / CENTER / ETC) — 등록 시 category 로 전달
    let code: String
    /// 드롭다운 표시명 (예: 예약/출석 관련)
    let label: String
}

/// 스웨거엔 배열만 표기돼 있으나 실제 응답은 {code, status, data}로 래핑돼 내려온다.
struct InquiryCategoryResponse: Codable {
    let data: [InquiryCategoryDto]
}

// MARK: - 문의 등록 (POST /api/inquiries)

/// 1:1 문의 등록 요청. title·content·category 모두 필수
/// - 디자인(CS_MO_2)엔 제목 입력칸이 없어, 내용 앞부분으로 제목을 만들어 보낸다 (기획 확정 전 임시 처리)
struct InquiryCreateDto: Codable {
    let category: String
    /// 문의 제목 (50자 이내)
    let title: String
    /// 문의 내용 (500자 이내)
    let content: String

    static let titleMaxLength = 50
    static let contentMaxLength = 500

    /// 내용의 첫 줄을 최대 50자까지 잘라 제목으로 사용
    static func makeTitle(from content: String) -> String {
        let firstLine = content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)
            .first?
            .trimmingCharacters(in: .whitespaces) ?? ""
        return String(firstLine.prefix(titleMaxLength))
    }
}

// MARK: - 나의 문의함 항목

/// 문의 처리 상태
enum InquiryStatus: String, Codable, Equatable {
    /// 접수완료: 등록 후 확인 전
    case received = "RECEIVED"
    /// 답변대기: 확인 후 답변 대기
    case inProgress = "IN_PROGRESS"
    /// 답변완료
    case answered = "ANSWERED"
}

/// 5a 문의 내역 유닛
struct InquiryDto: Codable, Equatable, Identifiable {
    let inquiryId: String
    let category: String?
    let categoryLabel: String?
    let title: String
    let content: String?
    /// RECEIVED / IN_PROGRESS / ANSWERED (알 수 없는 값이 와도 목록이 깨지지 않도록 문자열로 받는다)
    let status: String?
    /// 처리 상태 표시명 (예: 답변완료)
    let statusLabel: String?
    /// 관리자 답변. 답변 전에는 생략
    let answer: String?
    let createdAt: String?
    let answeredAt: String?

    var id: String { inquiryId }

    var inquiryStatus: InquiryStatus? { status.flatMap(InquiryStatus.init(rawValue:)) }

    /// 접수완료·답변대기는 펼쳐도 내용까지만 노출
    var isAnswered: Bool { inquiryStatus == .answered && !(answer ?? "").isEmpty }

    var statusText: String {
        if let statusLabel, !statusLabel.isEmpty { return statusLabel }
        switch inquiryStatus {
        case .received: return "접수완료"
        case .inProgress: return "답변대기"
        case .answered: return "답변완료"
        case nil: return ""
        }
    }
}

/// 나의 문의함 페이지 — 스웨거 응답 설명 "Page<InquiryDto>" (Spring Data Page 직렬화 형태)
/// 사용하는 필드만 정의하고 pageable·sort 등 나머지 필드는 무시한다.
struct InquiryPageDto: Codable, Equatable {
    /// 현재 페이지의 문의 목록 (최신순)
    let content: [InquiryDto]
    /// 마지막 페이지 여부
    let last: Bool?
    /// 현재 페이지 번호 (0부터 시작)
    let number: Int?
    /// 전체 페이지 수
    let totalPages: Int?
    /// 전체 문의 수
    let totalElements: Int?

    /// last가 없으면 number/totalPages로 판단
    var isLast: Bool {
        if let last { return last }
        if let number, let totalPages { return number + 1 >= totalPages }
        return content.isEmpty
    }
}

/// 스웨거엔 Page만 표기돼 있으나, 다른 API와 동일하게 {code, status, data}로 래핑돼 내려온다.
struct InquiryPageResponse: Codable {
    let data: InquiryPageDto
}

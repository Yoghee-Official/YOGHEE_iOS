//
//  MemberLookupModels.swift
//  YOGHEE
//
//  회원 조회(SM_MO_1) - 지도자 수강생 목록 (GET /api/leader/members)
//  수강권 정지/재개 (POST /api/leader/members/{userUuid}/tickets/pause|resume)
//

import Foundation

// MARK: - 수련 유형 탭 (2a 하루수련 / 정규수련 토글)
enum MemberLookupTab: CaseIterable, Equatable {
    case oneDay
    case regular

    var title: String {
        switch self {
        case .oneDay: return "하루수련"
        case .regular: return "정규수련"
        }
    }

    /// GET /api/leader/members `type` 파라미터 (O: 하루수련, R: 정규수련)
    var typeParameter: String {
        switch self {
        case .oneDay: return "O"
        case .regular: return "R"
        }
    }
}

// MARK: - 수강생 목록 항목
struct LeaderMemberDTO: Codable, Equatable, Identifiable {
    let userUuid: String
    let nickname: String?
    /// 회원명 (이름이 없으면 닉네임)
    let name: String?
    /// 회원ID / 간편로그인 ID. 간편로그인 회원은 로그인 종류(예: 카카오 로그인), 둘 다 없으면 닉네임
    let displayId: String?
    let profileImage: String?
    /// 주 이용 유형 (ONE_DAY / REGULAR). 탭(type)과 관계없이 이 지도자의 수련 전체 기준
    let mainUsageType: String?
    /// 주 이용 유형 표시명 (원데이·정규)
    let mainUsageTypeLabel: String?
    /// 신청 1회 이하면 NEW, 2회 이상이면 RETURNING (하루수련 탭 "신규회원" 태그)
    let memberStatus: MemberStatus?
    let classCount: Int?
    let classNames: [String]?
    let totalReservationCount: Int?
    /// 누적방문: 출석 처리된 예약 수 (결석·출석 미처리 제외)
    let attendedCount: Int?
    let upcomingReservationCount: Int?
    let lastVisitedAt: String?
    /// 최근 방문(마지막 예약 일자 기준): 취소되지 않은 예약 중 시작 시각이 지난 가장 최근 수련 시각
    let lastReservedAt: String?
    let nextReservationAt: String?
    /// 정규수련 재등록 회원 태그. 환불되지 않은 이용권을 2장 이상 구매했으면 true
    let reRegistered: Bool?
    /// 수강권 정지 회원(비활성화) 여부
    var ticketPaused: Bool?
    let activeTicketCount: Int?
    let remainingSessions: Int?
    /// 잔여횟수의 총 횟수 (횟수제 이용권이 없으면 생략)
    let totalSessions: Int?
    /// 정규수련 등록 개월 수 (사용 중·정지 이용권이 없으면 생략)
    let registeredMonths: Int?
    let latestTicketExpiry: String?
    /// 정규수련 잔여기간(일). 만료일 미정이면 생략
    let remainingDays: Int?

    var id: String { userUuid }

    var isTicketPaused: Bool { ticketPaused ?? false }

    /// 주 이용 유형 표시명. 서버 표시명 우선, 없으면 코드로 대체
    var usageTypeText: String? {
        if let label = mainUsageTypeLabel, !label.isEmpty { return label }
        switch mainUsageType {
        case "ONE_DAY": return "원데이"
        case "REGULAR": return "정규"
        default: return nil
        }
    }
}

// MARK: - 수강생 목록 페이지
struct LeaderMemberPageDTO: Codable, Equatable {
    let items: [LeaderMemberDTO]
    let totalCount: Int?
    let page: Int?
    let size: Int?
    let hasNext: Bool?
}

/// 스웨거상 래핑 없는 LeaderMemberListResponseDto로 보이나, 이 앱의 다른 API는 {code,status,data}로 래핑돼 있어
/// 두 형태 모두 디코딩되도록 처리한다.
struct LeaderMemberPageResponse: Codable {
    let data: LeaderMemberPageDTO

    private enum CodingKeys: String, CodingKey { case data }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let data = try? container.decode(LeaderMemberPageDTO.self, forKey: .data) {
            self.data = data
        } else {
            self.data = try LeaderMemberPageDTO(from: decoder)
        }
    }
}

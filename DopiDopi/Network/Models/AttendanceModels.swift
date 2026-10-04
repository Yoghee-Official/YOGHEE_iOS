//
//  AttendanceModels.swift
//  YOGHEE
//
//  지도자 마이페이지 "오늘의 수업" 출석체크 바텀시트 (피그마 node-id 3-13279) 전용 모델
//

import Foundation

// MARK: - 출석 상태
enum AttendanceStatus: String, Codable, Equatable {
    case REGISTERED
    case ATTENDED
    case CANCELLED
    case NOT_ATTENDED
}

// MARK: - 회원 유형 (동일 클래스 예약 이력 기준)
enum MemberStatus: String, Codable, Equatable {
    case NEW
    case RETURNING
}

// MARK: - 지도자 수련 세션 운영 정보
struct LeaderSessionDTO: Codable, Equatable {
    let sessionId: String
    let classId: String
    let className: String?
    let regionName: String?
    let startsAt: String?
    let endsAt: String?
    let maxCapacity: Int?
    let registeredCount: Int?
    let attendedCount: Int?
    let notAttendedCount: Int?
    let cancelledCount: Int?
    let bulkAttendanceAvailable: Bool?
    let attendanceManageable: Bool?
}

// MARK: - 지도자용 세션 예약 회원
struct LeaderSessionMemberDTO: Codable, Equatable, Identifiable {
    let reservationId: String
    let userUuid: String?
    let name: String?
    let displayId: String?
    let memberStatus: MemberStatus?
    let nickname: String?
    let cancelable: Bool?
    let attendeeCount: Int?
    var attendanceStatus: AttendanceStatus

    var id: String { reservationId }
}

// MARK: - 세션 출석 화면: 수련 정보 + 예약 회원 목록 (GET /api/leader/sessions/{sessionId}/members)
/// 스웨거 문서상 래핑 없이 바로 내려오는 것으로 보이나, 이 앱의 다른 API는 보통 {code,status,data} 형태로
/// 래핑돼 있어 실제 운영 응답이 어느 쪽이든 안전하게 디코딩되도록 두 형태 모두 시도한다.
struct LeaderSessionMembersResponse: Codable {
    let session: LeaderSessionDTO
    let members: [LeaderSessionMemberDTO]

    private enum CodingKeys: String, CodingKey { case data, session, members }
    private enum DataCodingKeys: String, CodingKey { case session, members }

    init(from decoder: Decoder) throws {
        // 1) 래핑 형태: {code, status, data: {session, members}}
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let dataContainer = try? container.nestedContainer(keyedBy: DataCodingKeys.self, forKey: .data),
           let session = try? dataContainer.decode(LeaderSessionDTO.self, forKey: .session),
           let members = try? dataContainer.decode([LeaderSessionMemberDTO].self, forKey: .members) {
            self.session = session
            self.members = members
            return
        }
        // 2) 언래핑 형태: 최상위에 바로 session/members
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try container.decode(LeaderSessionDTO.self, forKey: .session)
        self.members = try container.decode([LeaderSessionMemberDTO].self, forKey: .members)
    }

    // get<T: Codable>의 제네릭 제약을 만족시키기 위한 형식적 인코딩 (실제로 인코딩해서 보낼 일은 없음)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(session, forKey: .session)
        try container.encode(members, forKey: .members)
    }
}

// MARK: - 예약 회원 출석·결석 처리 요청 (POST /api/leader/sessions/{sessionId}/attendance)
struct UpdateAttendanceRequestDTO: Codable {
    let reservationIds: [String]
    let status: String
}

// MARK: - 지도자의 수강생 예약 취소 요청 (POST /api/leader/reservations/{reservationId}/cancel)
struct CancelReservationRequestDTO: Codable {
    let reason: String?
}

/// 응답 바디 형태가 임의적인(`"type": "object"`) 단순 처리 결과 엔드포인트용 디코딩 플레이스홀더
struct APIEmptyResponse: Codable {
    init() {}
    init(from decoder: Decoder) throws {}
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

//
//  ReservationHistoryModels.swift
//  YOGHEE
//
//  요기니 내역 보기(RC_MO_1) 화면 데이터 - GET /api/my/reservations (ReservationDto)
//

import Foundation

// MARK: - 2c / 2d: 탭
enum ReservationHistoryTab: CaseIterable {
    /// 2c: 예약/취소 항목 - 예약 완료된 정규/하루 수련 + 취소 완료 내역
    case reserved
    /// 2d: 만료 항목 - 완료된 내역
    case expired

    var title: String {
        switch self {
        case .reserved: return "예약 항목"
        case .expired: return "만료 항목"
        }
    }

    /// 목록이 비었을 때 방어문구
    var emptyMessage: String {
        switch self {
        case .reserved: return "예약 항목이 없습니다."
        case .expired: return "만료 항목이 없습니다."
        }
    }
}

// MARK: - 2a: 정렬 필터
enum ReservationHistorySort: String, CaseIterable {
    /// 최근 결제 또는 예약, 취소완료 기준
    case recent
    /// 결제 완료 기준 (결제 취소 포함)
    case paid
    /// 예약 완료 기준
    case reserved

    var title: String {
        switch self {
        case .recent: return "최신순"
        case .paid: return "결제순"
        case .reserved: return "예약순"
        }
    }
}

// MARK: - 예약 내역 응답
/// 스웨거상으로는 배열을 바로 반환하지만, 실제 응답은 다른 API와 동일하게 {code, status, data}로 래핑돼 내려옴
struct MyReservationListResponse: Codable {
    let code: Int
    let status: String
    let data: [ReservationDTO]
}

// MARK: - 예약 내역 (ReservationDto)
struct ReservationDTO: Codable, Identifiable, Equatable {
    /// 취소·환불 API 경로에 사용
    let reservationId: String
    let classId: String?
    let className: String?
    /// O: 하루수련, R: 정규수련
    let classType: String?
    let thumbnail: String?
    let centerId: String?
    let centerName: String?
    let address: String?
    /// 선생님(강사)명. 일정에 등록된 강사명, 없으면 수련을 개설한 지도자 닉네임
    let instructorName: String?
    let sessionId: String?
    /// 결제한 수강권 ID
    let userTicketId: String?
    let startsAt: String?
    let endsAt: String?
    /// REGISTERED / ATTENDED / CANCELLED / NOT_ATTENDED
    let attendanceStatus: String?
    /// 화면 표시 상태: UPCOMING / COMPLETED / CANCELLED
    let status: String?
    let paidAmount: Int?
    let paidAt: String?
    let reservedAt: String?
    let cancelledAt: String?
    let paymentStatus: String?
    let cancellable: Bool?
    let cancellationUnavailableReason: String?
    /// WRITABLE / WRITTEN / EXPIRED, 참석하지 않은 예약은 null
    let reviewStatus: String?
    let reviewButtonText: String?
    let reviewId: String?
    let reviewWritableUntil: String?

    var id: String { reservationId }

    var isRegular: Bool { classType == "R" }
    var isCancelled: Bool { status == "CANCELLED" }
    var isCompleted: Bool { status == "COMPLETED" }

    var startDate: Date? { ReservationDateParser.date(from: startsAt) }

    /// 알 수 없는 값이 와도 디코딩이 깨지지 않도록 문자열로 받고 여기서 변환
    var review: ReservationReviewStatus? { reviewStatus.flatMap(ReservationReviewStatus.init(rawValue:)) }

    /// "OOO 지도자님" (선생님명이 없으면 nil → 미노출)
    var instructorText: String? {
        guard let instructorName, !instructorName.isEmpty else { return nil }
        return "\(instructorName) 지도자님"
    }
}

// MARK: - 3e: 수련 기록(리뷰) 버튼 상태
enum ReservationReviewStatus: String {
    /// 수련 기록 남기기
    case writable = "WRITABLE"
    /// 수련 기록 보기
    case written = "WRITTEN"
    /// 작성 기간 만료 (버튼 미노출)
    case expired = "EXPIRED"
}

// MARK: - 일시 파싱

/// 스웨거상 date-time(ISO 8601)이지만 소수점 초 유무가 섞일 수 있고,
/// 타임존 없이 내려오는 경우(LocalDateTime)는 한국 시간으로 해석한다
enum ReservationDateParser {
    private static let isoFormatter = ISO8601DateFormatter()
    private static let isoFormatterWithFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    private static let localFormatters: [DateFormatter] = ["yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss"].map {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = $0
        return formatter
    }

    static func date(from string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }
        if let date = isoFormatterWithFraction.date(from: string) ?? isoFormatter.date(from: string) {
            return date
        }
        for formatter in localFormatters {
            if let date = formatter.date(from: string) { return date }
        }
        return nil
    }

    private static let dayFormatter = displayFormatter("yyyy년 MM월 dd일")
    private static let timeFormatter = displayFormatter("a h:mm")

    /// "2026년 02월 28일"
    static func dayText(_ date: Date?) -> String {
        guard let date else { return "" }
        return dayFormatter.string(from: date)
    }

    /// "오전 9:00"
    static func timeText(_ date: Date?) -> String {
        guard let date else { return "" }
        return timeFormatter.string(from: date)
    }

    /// DateFormatter 생성 비용이 커서 카드 렌더링마다 만들지 않도록 한 번만 생성해 재사용
    private static func displayFormatter(_ pattern: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = pattern
        return formatter
    }
}

//
//  MemberInfoModels.swift
//  YOGHEE
//
//  회원정보관리(MI_MO_1) 화면 데이터
//  - GET /api/my/info : 개인정보 조회 (수정 진입) → MyInfoDto
//  - PUT /api/my/info : 개인정보 변경 ← UpdateUserInfoDto
//

import Foundation

// MARK: - 조회 응답 (GET /api/my/info)

/// 스웨거 스키마에는 MyInfoDto만 표기돼 있으나, 서버는 모든 응답을 {code, status, data}로 감싸서 내려준다.
/// (예: /api/main 도 스웨거엔 MainApiDto로만 표기되지만 실제 응답은 래핑 형태)
struct MyInfoResponse: Codable {
    let code: Int
    let status: String
    let data: MyInfoDto
}

/// 개인정보 수정 진입 — 현재 계정에 등록된 정보
struct MyInfoDto: Codable, Equatable {
    /// 이름
    let name: String?
    /// 이메일 (로그인한 소셜 이메일)
    let email: String?
    /// 휴대폰 번호 (예: 01012345678)
    let phoneNo: String?
    /// 생년월일 (yyyy-MM-dd)
    let birthDate: String?
}

// MARK: - 변경 요청 (PUT /api/my/info)

/// 개인정보 변경 요청. 변경할 필드만 전달하며, null(미포함)인 필드는 변경되지 않는다.
/// 이메일·휴대폰번호는 서버에서 중복 검사 (409: EMAIL_ALREADY_EXISTS 등)
struct UpdateUserInfoDto: Codable {
    /// 이름 (최대 50자)
    var name: String?
    /// 생년월일 (yyyy-MM-dd)
    var birthDate: String?
    /// 이메일 (최대 100자) - MI_MO_1에서는 수정 불가라 보내지 않음
    var email: String?
    /// 휴대폰 번호 (최대 30자)
    var phoneNo: String?

    var isEmpty: Bool {
        name == nil && birthDate == nil && email == nil && phoneNo == nil
    }
}

// MARK: - 회원 탈퇴 (DA_MO_1)

/// 탈퇴 사유 (2a). 화면 노출 순서 = case 선언 순서
enum WithdrawalReasonType: String, Codable, CaseIterable {
    case lackOfClasses = "LACK_OF_CLASSES"
    case noPreferredStyle = "NO_PREFERRED_STYLE"
    case lackOfNearbyStudios = "LACK_OF_NEARBY_STUDIOS"
    case paymentInconvenient = "PAYMENT_INCONVENIENT"
    case serviceInconvenient = "SERVICE_INCONVENIENT"
    case notUsing = "NOT_USING"
    case takingABreak = "TAKING_A_BREAK"
    case switchingPlatform = "SWITCHING_PLATFORM"
    case unmetExpectations = "UNMET_EXPECTATIONS"
    case other = "OTHER"

    var title: String {
        switch self {
        case .lackOfClasses: return "예약 가능한 클래스/시간대가 부족해요."
        case .noPreferredStyle: return "원하는 요가 난이도/스타일이 없어요."
        case .lackOfNearbyStudios: return "우리 동네에 등록된 스튜디오가 부족해요."
        case .paymentInconvenient: return "결제/환불이 불편해요."
        case .serviceInconvenient: return "예약/취소/검색이 불편해요."
        case .notUsing: return "자주 이용하지 않아요."
        case .takingABreak: return "요가를 잠시 쉬게 되었어요."
        case .switchingPlatform: return "다른 요가 앱/플랫폼을 사용하려고요."
        case .unmetExpectations: return "기대했던 경험과 달라요."
        case .other: return "기타"
        }
    }

    /// 최대 중복 선택 개수 (reasonDetail 입력 시 자동 포함되는 OTHER도 포함)
    static let maxSelection = 3
}

/// POST /api/my/withdrawal 요청
struct WithdrawalRequestDto: Codable {
    /// 탈퇴 사유 코드 (1~3개)
    let reasonTypes: [WithdrawalReasonType]
    /// 기타 사유 직접 입력 (최대 500자). 입력하면 서버에서 OTHER로 처리
    let reasonDetail: String?

    static let maxDetailLength = 500
}

/// POST /api/my/withdrawal 응답 ({code, status, data} 래핑)
struct WithdrawalResponse: Codable {
    let code: Int
    let status: String
    let data: WithdrawalResponseDto
}

struct WithdrawalResponseDto: Codable {
    let withdrawn: Bool?
    let withdrawnAt: String?
    let message: String?
}

/// GET /api/my/withdrawal/check 응답 ({code, status, data} 래핑)
struct WithdrawalCheckResponse: Codable {
    let code: Int
    let status: String
    let data: WithdrawalCheckResponseDto
}

struct WithdrawalCheckResponseDto: Codable {
    let canWithdraw: Bool
    let blockers: [WithdrawalBlocker]?
    let upcomingReservationCount: Int?
    let paymentInProgressCount: Int?
    let ownedCenterCount: Int?

    /// 탈퇴 불가 안내 문구 (기획에 별도 얼럿 문구가 없어 사유별로 조합)
    var blockedMessage: String {
        "현재 탈퇴할 수 없어요.\n" + blockerLines
    }

    private var blockerLines: String {
        let lines = (blockers ?? []).map { blocker -> String in
            switch blocker {
            case .upcomingReservation:
                return "예정된 예약이 \(upcomingReservationCount ?? 0)건 있어요."
            case .paymentInProgress:
                return "처리 중인 결제가 \(paymentInProgressCount ?? 0)건 있어요."
            case .ownedCenter:
                return "등록한 요가원이 \(ownedCenterCount ?? 0)곳 있어요."
            case .unknown:
                return ""
            }
        }.filter { !$0.isEmpty }
        let reason = lines.isEmpty ? "" : lines.joined(separator: "\n") + "\n"
        return reason + "정리 후 다시 시도해 주세요."
    }
}

enum WithdrawalBlocker: String, Codable {
    case upcomingReservation = "UPCOMING_RESERVATION"
    case paymentInProgress = "PAYMENT_IN_PROGRESS"
    case ownedCenter = "OWNED_CENTER"
    case unknown

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = WithdrawalBlocker(rawValue: raw) ?? .unknown
    }
}

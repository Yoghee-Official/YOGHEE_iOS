//
//  NotificationModels.swift
//  YOGHEE
//
//  마이페이지 > 메세지함 (MS_MO_1, Figma 3-6174) 전용 모델
//  GET /api/notifications, GET /api/notifications/{id}, PUT /api/notifications/read-all, PUT /api/notifications/{id}/hide
//

import Foundation

// MARK: - 메세지함 탭
/// 2a: 전체 / 신규알림 / 공지사항 / 문의사항
/// 신규알림 탭은 별도 type 없이 ALL + readStatus=UNREAD 로 조회한다 (스웨거 type 파라미터 설명 참고)
enum MessageBoxTab: CaseIterable, Equatable {
    case all
    case unread
    case notice
    case inquiry

    var title: String {
        switch self {
        case .all: return "전체"
        case .unread: return "신규알림"
        case .notice: return "공지사항"
        case .inquiry: return "문의사항"
        }
    }

    /// 목록 조회·모두 읽음 API의 type 쿼리 값
    var typeParameter: String {
        switch self {
        case .all, .unread: return "ALL"
        case .notice: return "NOTICE"
        case .inquiry: return "INQUIRY"
        }
    }

    /// 목록 조회 API의 readStatus 쿼리 값
    var readStatusParameter: String {
        self == .unread ? "UNREAD" : "ALL"
    }
}

// MARK: - 발신자 유형
enum NotificationSenderType: String, Codable, Equatable {
    /// 전체 공지 (팀 요기)
    case SYSTEM
    /// 지도자 발송 메시지
    case LEADER
}

// MARK: - 메세지 목록 항목 (접힌 카드용, 본문 미포함)
struct NotificationListItemDTO: Codable, Equatable, Identifiable {
    let notificationId: String
    let type: String?
    let title: String
    let publishedAt: String?
    var isRead: Bool
    let senderType: NotificationSenderType?
    let senderName: String?
    let classId: String?
    let className: String?
    /// 지도자 메시지의 대상 클래스 대표이미지. 전체 공지는 null(앱 기본 로고 사용)
    let thumbnail: String?
    /// 수업장소 시/도, 시/군/구. 전체 공지는 필드 생략
    let sido: String?
    let sigungu: String?
    /// 수련 인원. 서버에서 999명 초과 시 "999+"로 내려준다. 전체 공지는 null
    let reservedCount: String?
    /// 공개일의 요일 (1=월 ~ 7=일)
    let dayOfWeek: Int?

    var id: String { notificationId }

    private enum CodingKeys: String, CodingKey {
        case notificationId, type, title, publishedAt, isRead, senderType, senderName
        case classId, className, thumbnail, sido, sigungu, reservedCount, dayOfWeek
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        notificationId = try container.decode(String.self, forKey: .notificationId)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
        isRead = try container.decodeIfPresent(Bool.self, forKey: .isRead) ?? false
        senderType = try? container.decodeIfPresent(NotificationSenderType.self, forKey: .senderType)
        senderName = try container.decodeIfPresent(String.self, forKey: .senderName)
        classId = try container.decodeIfPresent(String.self, forKey: .classId)
        className = try container.decodeIfPresent(String.self, forKey: .className)
        thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        sido = try container.decodeIfPresent(String.self, forKey: .sido)
        sigungu = try container.decodeIfPresent(String.self, forKey: .sigungu)
        // 스웨거상 string("999+")이지만 숫자로 내려와도 깨지지 않도록 둘 다 허용
        if let text = try? container.decodeIfPresent(String.self, forKey: .reservedCount) {
            reservedCount = text
        } else if let number = try? container.decodeIfPresent(Int.self, forKey: .reservedCount) {
            reservedCount = String(number)
        } else {
            reservedCount = nil
        }
        dayOfWeek = try container.decodeIfPresent(Int.self, forKey: .dayOfWeek)
    }

    init(
        notificationId: String,
        type: String? = nil,
        title: String,
        publishedAt: String? = nil,
        isRead: Bool,
        senderType: NotificationSenderType? = nil,
        senderName: String? = nil,
        classId: String? = nil,
        className: String? = nil,
        thumbnail: String? = nil,
        sido: String? = nil,
        sigungu: String? = nil,
        reservedCount: String? = nil,
        dayOfWeek: Int? = nil
    ) {
        self.notificationId = notificationId
        self.type = type
        self.title = title
        self.publishedAt = publishedAt
        self.isRead = isRead
        self.senderType = senderType
        self.senderName = senderName
        self.classId = classId
        self.className = className
        self.thumbnail = thumbnail
        self.sido = sido
        self.sigungu = sigungu
        self.reservedCount = reservedCount
        self.dayOfWeek = dayOfWeek
    }

    /// 지도자 메시지 여부 (senderType이 없으면 classId 유무로 판단)
    var isLeaderMessage: Bool {
        if let senderType { return senderType == .LEADER }
        return classId != nil
    }
}

// MARK: - 메세지 목록 응답 (GET /api/notifications)
struct NotificationListDTO: Codable, Equatable {
    let items: [NotificationListItemDTO]
    let unreadCount: Int?
    let page: Int?
    let size: Int?
    let hasNext: Bool?
}

// MARK: - 메세지 상세 응답 (GET /api/notifications/{notificationId}) - 조회 시 자동 읽음 처리
struct NotificationDetailDTO: Codable, Equatable {
    let notificationId: String
    let title: String?
    let content: String?
    let publishedAt: String?
    let isRead: Bool?
}

// MARK: - 모두 읽음 응답 (PUT /api/notifications/read-all)
struct NotificationReadAllDTO: Codable, Equatable {
    let updatedCount: Int?
    let unreadCount: Int?
}

// MARK: - 숨김(삭제) 응답 (PUT /api/notifications/{notificationId}/hide)
struct NotificationHideDTO: Codable, Equatable {
    let notificationId: String?
    let hidden: Bool?
}

// MARK: - 공통 응답 래퍼
/// 스웨거 문서상 알림 API 응답은 {code,status,data} 래핑 없이 DTO를 바로 반환하는 것으로 보이나,
/// 이 앱의 다른 API는 전부 래핑돼 있어 실제 응답이 어느 쪽이든 디코딩되도록 두 형태 모두 시도한다.
struct NotificationAPIResponse<T: Codable>: Codable {
    let data: T

    private enum CodingKeys: String, CodingKey { case data }

    init(from decoder: Decoder) throws {
        // 1) 래핑 형태: {code, status, data: {...}}
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let wrapped = try? container.decode(T.self, forKey: .data) {
            self.data = wrapped
            return
        }
        // 2) 언래핑 형태: 최상위가 바로 DTO
        let single = try decoder.singleValueContainer()
        self.data = try single.decode(T.self)
    }

    // get<T: Codable>의 제네릭 제약을 만족시키기 위한 형식적 인코딩 (실제로 인코딩해서 보낼 일은 없음)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }
}

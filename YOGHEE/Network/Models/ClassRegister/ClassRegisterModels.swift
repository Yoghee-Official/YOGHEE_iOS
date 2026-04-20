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

struct AmenityCodeListDTO: Codable, Equatable {
    let amenity: [CodeInfoDTO]
    let facility: [CodeInfoDTO]
}

struct CodeInfoDTO: Codable, Identifiable, Hashable {
    let id: String
    let name: String
}

// MARK: - 카카오 우편번호 서비스 선택 결과 (postcode.map.daum.net/guide oncomplete 데이터)

/// 카카오 우편번호 서비스에서 사용자가 선택한 주소 정보 (oncomplete 인자 기준)
struct KakaoPostcodeResult: Codable, Equatable {
    /// 국가기초구역번호 (새 우편번호, 5자리)
    let zonecode: String
    /// 기본 주소 (사용자가 선택한 타입에 따른 도로명 또는 지번)
    let address: String
    /// 도로명 주소 (없을 수 있음)
    let roadAddress: String
    /// 지번 주소 (없을 수 있음)
    let jibunAddress: String
    /// 사용자가 선택한 주소 타입: R(도로명), J(지번)
    let userSelectedType: String
    /// 건물명 (없을 수 있음)
    let buildingName: String?
    /// 도/시 이름 (광역시/도)
    let sido: String?
    /// 시/군/구 이름 (시/구)
    let sigungu: String?
}

// MARK: - 요가원 정보 목록 조회 API (GET /api/center)

/// 요가원 목록 조회 API 응답 (code, status, data 배열)
struct CenterListResponse: Codable {
    let code: Int
    let status: String
    let data: [CenterBaseDTO]
}

/// 등록된 요가원 한 건 (수련 장소 등록 화면 2b용)
struct CenterBaseDTO: Codable, Identifiable, Equatable {
    let centerId: String
    let name: String
    let address: String
    let createdAt: String
    
    var id: String { centerId }
}

// MARK: - 요가원 정보 등록 API (POST /api/center)

/// 신규 요가원 등록 요청 바디 (NewCenterDto). 도로명/지번은 둘 중 하나만 있어도 됨.
struct NewCenterDto: Codable {
    var name: String
    var description: String?
    var thumbnail: String?
    var masterId: String?
    var depth1: String?
    var depth2: String?
    var depth3: String?
    var roadAddress: String?
    var jibunAddress: String?
    var zonecode: String?
    var addressDetail: String?
    var fullAddress: String?
    var amenityIds: [String]?
}

/// 요가원 등록 API 응답 (200 시 data: 메시지 문자열)
struct NewCenterResponse: Codable {
    let code: Int
    let status: String
    let data: String?
}

// MARK: - 이미지 Presigned URL 발급 (POST /api/image/presign)

/// 업로드할 이미지 파일 정보 (presign 요청용)
struct ImageUploadInfoDto: Codable {
    let fileName: String
    let contentType: String
    let width: Int
    let height: Int
    let fileSize: Int
}

/// Presigned URL 발급 요청 바디 (서버 필드명: type)
struct ImageUploadDto: Codable {
    let type: String   // "class" | "center" | "profile" | "license"
    let files: [ImageUploadInfoDto]
}

/// Presigned URL 발급 응답 - 파일별 presignedUrl, imageKey
struct PresignFileResponseDto: Codable {
    let fileName: String
    let contentType: String
    let width: Int
    let height: Int
    let fileSize: Int
    let imageKey: String
    let presignedUrl: String
}

/// Presigned URL 발급 응답 (API는 code/status/data 래핑)
struct ImagePresignResponse: Codable {
    let type: String?
    let files: [PresignFileResponseDto]
}

/// Presigned API 전체 응답 (code, status, data)
struct ImagePresignApiResponse: Codable {
    let code: Int
    let status: String
    let data: ImagePresignResponse
}

// MARK: - 클래스 이미지 등록 (수련원 이미지, 최대 20장)

/// 등록된 수련원 이미지 한 장 (드래그 순서·삭제용). 업로드 완료 시 imageKey 저장.
struct ClassRegisterImageItem: Identifiable, Equatable {
    let id: String
    let imageData: Data
    /// 업로드/처리 중이면 true, 완료되면 false (로딩 시 placeholder 표시)
    var isLoading: Bool
    /// Presigned 업로드 후 서버가 준 imageKey (클래스 등록 API images 배열에 사용)
    var imageKey: String?
    
    init(id: String, imageData: Data, isLoading: Bool = true, imageKey: String? = nil) {
        self.id = id
        self.imageData = imageData
        self.isLoading = isLoading
        self.imageKey = imageKey
    }
    
    static func == (lhs: ClassRegisterImageItem, rhs: ClassRegisterImageItem) -> Bool {
        lhs.id == rhs.id && lhs.isLoading == rhs.isLoading && lhs.imageKey == rhs.imageKey
    }
}

// MARK: - 환불 기준 한 줄 (수련 시작 N시간 전 N% 환불)
struct RefundRuleRow: Identifiable, Equatable {
    let id: String
    var hoursBefore: Int
    var percent: Int
}

// MARK: - 정규 수련 금액 플랜 (기간권 / 회차권)

struct RegularPricePlan: Identifiable, Equatable {
    /// API ticketType 값과 일치
    enum PlanType: String, Equatable {
        case period  = "PERIOD"   // 기간권
        case session = "SESSION"  // 회차권
    }

    let id: String              // 로컬 식별용 UUID
    var planType: PlanType      // ticketType
    var ticketName: String      // 수강권 이름 (앱에서 자동 생성)
    var price: Int              // 수강권 가격(원) — 필수
    /// PERIOD 전용: 유효 개월 수 (validMonths)
    var validMonths: Int
    /// PERIOD 전용: 주 횟수(회) (weeklyCount)
    var weeklyCount: Int
    /// SESSION 전용: 총 수강 가능 횟수 (totalSessions)
    var totalSessions: Int

    init(
        id: String = UUID().uuidString,
        planType: PlanType,
        ticketName: String = "",
        price: Int = 0,
        validMonths: Int = 1,
        weeklyCount: Int = 1,
        totalSessions: Int = 10
    ) {
        self.id = id
        self.planType = planType
        self.ticketName = ticketName
        self.price = price
        self.validMonths = validMonths
        self.weeklyCount = weeklyCount
        self.totalSessions = totalSessions
    }

    var formattedPrice: String {
        let fmt = NumberFormatter(); fmt.numberStyle = .decimal
        return (fmt.string(from: NSNumber(value: price)) ?? "0") + "원"
    }

    var displayLabel: String {
        switch planType {
        case .period:  return "기간권"
        case .session: return "회차권"
        }
    }
}

// MARK: - 정규 수련 휴무 (공휴일 칩)

/// 공휴일 휴무 선택용 고정 목록. rawValue = 상태 추적 키 (API 전송 시 apiValues로 변환)
enum RegularPublicHoliday: String, CaseIterable, Identifiable, Hashable {
    case newYear        = "NEW_YEAR_DAY"
    case seollal        = "SEOLLAL"               // UI 칩 — 설날 연휴 전체
    case independence   = "INDEPENDENCE_MOVEMENT_DAY"
    case childrenDay    = "CHILDREN_DAY"
    case buddhaBirthday = "BUDDHA_BIRTHDAY"
    case memorialDay    = "MEMORIAL_DAY"
    case liberationDay  = "LIBERATION_DAY"
    case foundationDay  = "NATIONAL_FOUNDATION_DAY"
    case hangulDay      = "HANGEUL_DAY"
    case chuseok        = "CHUSEOK"               // UI 칩 — 추석 연휴 전체
    case christmas      = "CHRISTMAS_DAY"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newYear:        return "신정"
        case .seollal:        return "연휴 | 설날 당일 | 연휴"
        case .independence:   return "삼일절"
        case .childrenDay:    return "어린이날"
        case .buddhaBirthday: return "석가탄신일"
        case .memorialDay:    return "현충일"
        case .liberationDay:  return "광복절"
        case .foundationDay:  return "개천절"
        case .hangulDay:      return "한글날"
        case .chuseok:        return "연휴 | 추석 당일 | 연휴"
        case .christmas:      return "크리스마스"
        }
    }

    /// API 전송 시 실제로 보낼 문자열 배열.
    /// "설,추석 당일만 휴무" 프리셋 여부에 따라 호출 시 조정 필요.
    var fullApiValues: [String] {
        switch self {
        case .seollal: return ["SEOLLAL_PREV", "SEOLLAL_DAY", "SEOLLAL_NEXT"]
        case .chuseok: return ["CHUSEOK_PREV", "CHUSEOK_DAY", "CHUSEOK_NEXT"]
        default:       return [rawValue]
        }
    }

    /// "설,추석 당일만 휴무" 프리셋일 때 당일 단일 API 값 (해당 없으면 nil)
    var dayOnlyApiValue: String? {
        switch self {
        case .seollal: return "SEOLLAL_DAY"
        case .chuseok: return "CHUSEOK_DAY"
        default:       return nil
        }
    }

    static var allHolidayIds: Set<String> {
        Set(allCases.map(\.rawValue))
    }

    /// 설·추석 당일만 휴무 프리셋
    static var seolChuseokOnlyIds: Set<String> {
        [seollal.rawValue, chuseok.rawValue]
    }
}

// MARK: - NewScheduleDTO (클래스 등록 시 schedules 배열 요소)

/// API LocalTime (hour, minute, second, nano)
struct LocalTimeDTO: Codable, Equatable {
    let hour: Int
    let minute: Int
    let second: Int
    let nano: Int
    
    init(hour: Int, minute: Int, second: Int = 0, nano: Int = 0) {
        self.hour = hour
        self.minute = minute
        self.second = second
        self.nano = nano
    }
    
    /// "HH:mm" 형식 문자열
    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }
}

/// 스케줄 정보 (NewClassDto.schedules 배열 요소)
struct NewScheduleDTO: Codable, Equatable, Identifiable {
    var scheduleId: String?
    /// 클라이언트에서 고유 식별용 (API 전송 제외, 복사 시 중복 id 방지)
    var localId: String?
    let dates: [String]           // "yyyy-MM-dd" 형식
    let startTime: LocalTimeDTO
    let endTime: LocalTimeDTO
    let minCapacity: Int
    let maxCapacity: Int
    let name: String
    /// 지도자(메모) — UI 전용, Codable/API에는 포함하지 않음
    var instructorNote: String
    
    var id: String { scheduleId ?? localId ?? "\(name)-\(dates.joined())-\(startTime.timeString)" }
    
    enum CodingKeys: String, CodingKey {
        case scheduleId, dates, startTime, endTime, minCapacity, maxCapacity, name
    }
    
    init(scheduleId: String?, localId: String? = nil, dates: [String], startTime: LocalTimeDTO, endTime: LocalTimeDTO, minCapacity: Int, maxCapacity: Int, name: String, instructorNote: String = "") {
        self.scheduleId = scheduleId
        self.localId = localId
        self.dates = dates
        self.startTime = startTime
        self.endTime = endTime
        self.minCapacity = minCapacity
        self.maxCapacity = maxCapacity
        self.name = name
        self.instructorNote = instructorNote
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scheduleId = try container.decodeIfPresent(String.self, forKey: .scheduleId)
        localId = nil
        dates = try container.decode([String].self, forKey: .dates)
        startTime = try container.decode(LocalTimeDTO.self, forKey: .startTime)
        endTime = try container.decode(LocalTimeDTO.self, forKey: .endTime)
        minCapacity = try container.decode(Int.self, forKey: .minCapacity)
        maxCapacity = try container.decode(Int.self, forKey: .maxCapacity)
        name = try container.decode(String.self, forKey: .name)
        instructorNote = ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(scheduleId, forKey: .scheduleId)
        try container.encode(dates, forKey: .dates)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(minCapacity, forKey: .minCapacity)
        try container.encode(maxCapacity, forKey: .maxCapacity)
        try container.encode(name, forKey: .name)
    }
}

// MARK: - 클래스 등록 API (POST /api/class)

/// 스케줄 항목 (API는 startTime/endTime 문자열 "HH:mm")
struct ClassRegisterScheduleItemDto: Codable {
    let scheduleId: String?
    let dates: [String]?
    /// [Regular 전용] 수업 요일 (1=월, 2=화, 3=수, 4=목, 5=금, 6=토, 7=일)
    let dayOfWeek: Int?
    let startTime: String
    let endTime: String
    let minCapacity: Int
    let maxCapacity: Int
    let name: String
}

/// 환불 정책 한 줄
struct ClassRegisterRefundPolicyDto: Codable {
    let hoursBeforeClass: Int
    let refundRate: Int
}

/// 정책 (할인·안내·환불)
struct ClassRegisterPolicyDto: Codable {
    let discountPrice: Int?
    let discountRate: Int?
    let reservationNote: String?
    let refundPolicies: [ClassRegisterRefundPolicyDto]?
}

/// 수강권 항목 (정규 전용)
struct ClassRegisterTicketDto: Codable {
    let ticketId: String?       // 신규 시 nil
    let ticketType: String      // "PERIOD" | "SESSION"
    let ticketName: String
    let price: Int
    let validMonths: Int?       // PERIOD 전용: 유효 개월 수
    let weeklyCount: Int?       // PERIOD 전용: 주 횟수
    let totalSessions: Int?     // SESSION 전용: 총 수강 횟수
}

/// 휴무 정책 (정규 전용)
struct ClassRegisterHolidayPolicyDto: Codable {
    let weeklyOffDays: [Int]?
    let publicHolidays: [String]?
}

/// POST /api/class 요청 바디
struct ClassRegisterRequestDto: Codable {
    /// 수련 유형: 원데이 "O", 정규 "R"
    let type: String
    let classId: String?
    let name: String
    let description: String?
    let centerId: String?
    let featureIds: [String]?
    let schedules: [ClassRegisterScheduleItemDto]
    let images: [String]?
    let price: Int
    let categoryIds: [String]?
    let policy: ClassRegisterPolicyDto?
    let holidayPolicy: ClassRegisterHolidayPolicyDto?  // 정규 전용
    let tickets: [ClassRegisterTicketDto]?              // 정규 전용
}

/// 클래스 등록 API 응답 (code, status, data)
struct ClassRegisterResponse: Codable {
    let code: Int
    let status: String
    let data: String?
}

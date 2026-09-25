//
//  ClassRegisterModels.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/27/26.
//

import Foundation

// MARK: - 코드 데이터 컨테이너

struct AmenityCodeListDTO: Equatable {
    let amenity: [CodeInfoDTO]
    let facility: [CodeInfoDTO]
}

struct CodeInfoDTO: Identifiable, Hashable {
    let id: String
    let name: String
}

// MARK: - 하드코딩 코드 목록 (구 GET /api/main/code 대체)

enum YogaCodeHardcoded {
    /// 전문 수련 유형 (ashtanga, hatha, vinyasa 등 요가 스타일)
    static let types: [CodeInfoDTO] = [
        CodeInfoDTO(id: "ashtanga",       name: "아쉬탕가"),
        CodeInfoDTO(id: "bepros_flow",    name: "비프로스플로우"),
        CodeInfoDTO(id: "flying_yoga",    name: "플라잉 요가"),
        CodeInfoDTO(id: "hatha",          name: "하타"),
        CodeInfoDTO(id: "inside_flow",    name: "인사이드플로우"),
        CodeInfoDTO(id: "iyengar",        name: "아헹가"),
        CodeInfoDTO(id: "meditation",     name: "명상"),
        CodeInfoDTO(id: "partner_yoga",   name: "파트너 요가"),
        CodeInfoDTO(id: "pet_yoga",       name: "펫요가"),
        CodeInfoDTO(id: "props_yoga",     name: "소도구 요가"),
        CodeInfoDTO(id: "sivananda",      name: "쉬바난다"),
        CodeInfoDTO(id: "traditional_yoga", name: "전통 요가"),
        CodeInfoDTO(id: "unique_yoga",    name: "이색 요가"),
        CodeInfoDTO(id: "vinyasa",        name: "빈야사"),
        CodeInfoDTO(id: "yin_yoga",       name: "인요가"),
    ]

    /// 수련 카테고리 (강도·스타일 분류)
    static let categories: [CodeInfoDTO] = [
        CodeInfoDTO(id: "advanced",  name: "숙련자"),
        CodeInfoDTO(id: "beginner",  name: "초심자"),
        CodeInfoDTO(id: "flow",      name: "플로우"),
        CodeInfoDTO(id: "indoor",    name: "실내"),
        CodeInfoDTO(id: "outdoor",   name: "야외"),
        CodeInfoDTO(id: "power",     name: "파워"),
        CodeInfoDTO(id: "relax",     name: "릴렉스"),
        CodeInfoDTO(id: "therapy",   name: "테라피"),
    ]

    /// 이용 대상
    static let targets: [CodeInfoDTO] = [
        CodeInfoDTO(id: "kids_yoga",      name: "키즈 요가"),
        CodeInfoDTO(id: "men_only",       name: "남성 전용"),
        CodeInfoDTO(id: "others",         name: "기타"),
        CodeInfoDTO(id: "prenatal_yoga",  name: "임산부 요가"),
        CodeInfoDTO(id: "unisex",         name: "남녀 공용"),
        CodeInfoDTO(id: "women_only",     name: "여성 전용"),
    ]

    /// 특징 (수련 장점 - 어디에 도움되는 수업인지)
    static let features: [CodeInfoDTO] = [
        CodeInfoDTO(id: "balance",   name: "중심 잡기, 안정성, 자세 정렬에 집중하는 수련"),
        CodeInfoDTO(id: "beginner",  name: "요가 입문자, 기본 동작과 호흡 설명 중심"),
        CodeInfoDTO(id: "breath",    name: "호흡·이완 중심, 심리적 안정"),
        CodeInfoDTO(id: "flow",      name: "기본 수련 경험이 있고 흐름 있는 동작"),
        CodeInfoDTO(id: "relax",     name: "허리·골반 주변 이완 및 안정"),
        CodeInfoDTO(id: "stretch",   name: "몸이 뻣뻣하거나 스트레칭 위주 수련"),
    ]

    /// 편의시설 및 제공물품
    static let amenities = AmenityCodeListDTO(
        amenity: [
            CodeInfoDTO(id: "air_purifier",     name: "공기청정기"),
            CodeInfoDTO(id: "blanket",          name: "담요"),
            CodeInfoDTO(id: "block",            name: "블럭"),
            CodeInfoDTO(id: "bolster",          name: "볼스터"),
            CodeInfoDTO(id: "cotton_swab",      name: "면봉"),
            CodeInfoDTO(id: "dehumidifier",     name: "제습기"),
            CodeInfoDTO(id: "foam_roller",      name: "폼롤러"),
            CodeInfoDTO(id: "hair_dryer",       name: "드라이기"),
            CodeInfoDTO(id: "hair_tie",         name: "머리끈"),
            CodeInfoDTO(id: "incense",          name: "인센스"),
            CodeInfoDTO(id: "massage_ball",     name: "마사지볼"),
            CodeInfoDTO(id: "mat",              name: "매트"),
            CodeInfoDTO(id: "mirror",           name: "거울"),
            CodeInfoDTO(id: "sanitizer",        name: "소독액"),
            CodeInfoDTO(id: "shower_supplies",  name: "사워용품"),
            CodeInfoDTO(id: "singing_bowl",     name: "싱잉볼"),
            CodeInfoDTO(id: "strap",            name: "스트랩"),
            CodeInfoDTO(id: "towel",            name: "타올"),
            CodeInfoDTO(id: "water_purifier",   name: "정수기"),
            CodeInfoDTO(id: "wet_wipes",        name: "물티슈"),
            CodeInfoDTO(id: "wifi",             name: "Wifi"),
        ],
        facility: [
            CodeInfoDTO(id: "fitness_zone",       name: "피트니스존"),
            CodeInfoDTO(id: "indoor_restroom",    name: "내부화장실"),
            CodeInfoDTO(id: "men_changing_room",  name: "남자탈의실"),
            CodeInfoDTO(id: "outdoor_restroom",   name: "외부화장실"),
            CodeInfoDTO(id: "personal_locker",    name: "개인사물함"),
            CodeInfoDTO(id: "powder_room",        name: "파우더룸"),
            CodeInfoDTO(id: "shoe_rack",          name: "신발장"),
            CodeInfoDTO(id: "shower_room",        name: "샤워실"),
            CodeInfoDTO(id: "stretching_zone",    name: "스트레칭존"),
            CodeInfoDTO(id: "women_changing_room", name: "여자탈의실"),
        ]
    )
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
    let latitude: Double?
    let longitude: Double?
    let createdAt: String

    var id: String { centerId }
}

/// 요가원 상세 조회 응답 (GET /api/center/{centerId})
/// 수정 화면을 다시 채우거나(주소 필드), 미리보기에서 위경도·보유물품 표시에 사용
struct CenterDetailDto: Codable {
    let centerId: String?
    let name: String?
    let description: String?
    let sido: String?
    let sigungu: String?
    let roadAddress: String?
    let jibunAddress: String?
    let zonecode: String?
    let detailAddress: String?
    let latitude: Double?
    let longitude: Double?
    /// 현재 선택된 제공물품·편의시설 코드 (전체 선택지는 YogaCodeHardcoded.amenities 참고)
    let amenityCodes: [String]?
}

/// GET /api/center/{centerId} 응답 파싱용 래퍼.
/// 스웨거 스키마는 {code,status,data} 래핑 없이 CenterDetailDto를 바로 내려주는 것처럼 보이지만,
/// 이 앱의 다른 API는 전부 래핑돼 있어 실제 운영 응답이 어느 쪽이든 안전하게 디코딩한다.
struct CenterDetailResponse: Codable {
    let data: CenterDetailDto

    private enum CodingKeys: String, CodingKey { case data }

    init(from decoder: Decoder) throws {
        // 1) 래핑 형태: {code, status, data: {...}}
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let wrapped = try? container.decode(CenterDetailDto.self, forKey: .data) {
            self.data = wrapped
            return
        }
        // 2) 언래핑 형태: 최상위가 바로 CenterDetailDto
        let single = try decoder.singleValueContainer()
        self.data = try single.decode(CenterDetailDto.self)
    }

    // get<T: Codable>의 제네릭 제약을 만족시키기 위한 형식적 인코딩 (실제로 인코딩해서 보낼 일은 없음)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }
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
    var amenityCodes: [String]?
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

// MARK: - 정규 수련 휴무 (공휴일 칩)

/// 공휴일 휴무 선택용 고정 목록. rawValue = 상태 추적 키 (API 전송 시 apiValues로 변환)
enum RegularPublicHoliday: String, CaseIterable, Identifiable, Hashable {
    case newYear        = "NEW_YEAR_DAY"
    case seollalDay     = "SEOLLAL_DAY"
    case seollalHoliday = "SEOLLAL_HOLIDAY"
    case independence   = "INDEPENDENCE_MOVEMENT_DAY"
    case childrenDay    = "CHILDREN_DAY"
    case buddhaBirthday = "BUDDHA_BIRTHDAY"
    case memorialDay    = "MEMORIAL_DAY"
    case liberationDay  = "LIBERATION_DAY"
    case foundationDay  = "NATIONAL_FOUNDATION_DAY"
    case hangulDay      = "HANGEUL_DAY"
    case chuseokDay     = "CHUSEOK_DAY"
    case chuseokHoliday = "CHUSEOK_HOLIDAY"
    case christmas      = "CHRISTMAS_DAY"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newYear:        return "신정"
        case .seollalDay:     return "설날 당일"
        case .seollalHoliday: return "설날 연휴"
        case .independence:   return "삼일절"
        case .childrenDay:    return "어린이날"
        case .buddhaBirthday: return "석가탄신일"
        case .memorialDay:    return "현충일"
        case .liberationDay:  return "광복절"
        case .foundationDay:  return "개천절"
        case .hangulDay:      return "한글날"
        case .chuseokDay:     return "추석 당일"
        case .chuseokHoliday: return "추석 연휴"
        case .christmas:      return "크리스마스"
        }
    }

    /// API 전송 시 실제로 보낼 문자열 배열.
    var apiValues: [String] {
        switch self {
        case .seollalHoliday: return ["SEOLLAL_PREV", "SEOLLAL_NEXT"]
        case .chuseokHoliday: return ["CHUSEOK_PREV", "CHUSEOK_NEXT"]
        default:       return [rawValue]
        }
    }

    static var allHolidayIds: Set<String> {
        Set(allCases.map(\.rawValue))
    }
}

// MARK: - 정규수련 "수련 달" 선택 규칙 (등록 화면 2b 드롭다운 · 결과보기 미리보기 공용)

/// 이번 달부터 +6개월까지만 선택 가능, 과거 달 제외 (단일 선택) — 등록 화면과 결과보기 미리보기가 동일한 규칙을 쓰도록 공용화
enum PracticeMonthOption {
    /// 이번 달부터 +6개월까지의 각 달 1일 Date 목록
    static func selectableMonths(from now: Date = Date()) -> [Date] {
        let cal = Calendar.current
        let startOfThisMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? now
        return (0...6).compactMap { cal.date(byAdding: .month, value: $0, to: startOfThisMonth) }
    }

    /// 화면 표시용, 예: "2026년 9월"
    static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f
    }()

    /// 스케줄 태그·서버 전송용 키, 예: "2026-09"
    static let keyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM"
        return f
    }()
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
    /// [Regular 전용] 이 스케줄이 적용되는 달 ("yyyy-MM"). UI 전용, Codable/API에는 포함하지 않음.
    /// 등록 시 `ClassRegisterContainer.registerClass()`에서 연/월로 분리되어
    /// `ClassRegisterMonthlyScheduleDto`(서버 스펙: MonthlyScheduleDto, 2026-09-20 배포)로 변환·전송된다.
    var practiceMonth: String?

    var id: String { scheduleId ?? localId ?? "\(name)-\(dates.joined())-\(startTime.timeString)" }

    enum CodingKeys: String, CodingKey {
        case scheduleId, dates, startTime, endTime, minCapacity, maxCapacity, name
    }

    init(scheduleId: String?, localId: String? = nil, dates: [String], startTime: LocalTimeDTO, endTime: LocalTimeDTO, minCapacity: Int, maxCapacity: Int, name: String, instructorNote: String = "", practiceMonth: String? = nil) {
        self.scheduleId = scheduleId
        self.localId = localId
        self.dates = dates
        self.startTime = startTime
        self.endTime = endTime
        self.minCapacity = minCapacity
        self.maxCapacity = maxCapacity
        self.name = name
        self.instructorNote = instructorNote
        self.practiceMonth = practiceMonth
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
        practiceMonth = nil
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
    /// [하루수련 전용] 신규 일정은 하나 이상, 기존 scheduleId 수정은 최대 한 날짜
    let dates: [String]?
    /// [Regular 전용] 수업 요일 (1=월, 2=화, 3=수, 4=목, 5=금, 6=토, 7=일)
    let dayOfWeek: Int?
    let startTime: String
    let endTime: String
    let minCapacity: Int
    let maxCapacity: Int
    let name: String
    /// 해당 스케줄을 진행하는 강사명 (기존 instructorNote 요청 키도 서버가 입력 호환하지만, 신규 스펙은 이 키를 사용)
    let instructorName: String?
}

/// [정규수련 전용] 월별 시간표 한 묶음 (연/월 + 그 달의 전체 스케줄).
/// 2026-09-20 배포된 스웨거 스펙(MonthlyScheduleDto) 반영 — 수정 시 schedules가 빈 배열이면 해당 월 시간표 전체 삭제.
struct ClassRegisterMonthlyScheduleDto: Codable {
    let year: Int
    let month: Int
    let schedules: [ClassRegisterScheduleItemDto]
}

/// 환불 정책 한 줄
struct ClassRegisterRefundPolicyDto: Codable {
    let hoursBeforeClass: Int
    let refundRate: Int
}

/// 정책 (할인·안내·환불)
struct ClassRegisterPolicyDto: Codable {
    /// 할인율(%), 1~100. 할인 사용 시 필수
    let discountRate: Int?
    /// 할인 적용 시작일(포함), yyyy-MM-dd. 할인율 입력 시 필수
    let discountStartDate: String?
    /// 할인 적용 종료일(포함), yyyy-MM-dd. 할인율 입력 시 필수
    let discountEndDate: String?
    let reservationNote: String?
    let refundPolicies: [ClassRegisterRefundPolicyDto]?
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
    let featureCodes: [String]?
    /// [하루수련 전용] 날짜별 일정
    let schedules: [ClassRegisterScheduleItemDto]?
    /// [정규수련 전용] 월별 시간표 목록. 여러 연월을 한 요청에 등록 가능
    let monthlySchedules: [ClassRegisterMonthlyScheduleDto]?
    let images: [String]?
    let price: Int
    let categoryCodes: [String]?
    let policy: ClassRegisterPolicyDto?
    let holidayPolicy: ClassRegisterHolidayPolicyDto?  // 정규 전용
    // tickets(수강권) 필드 없음: 2026-09 스웨거 기준 정규수련 MVP는 등록 요청에서 가격/수강권 개념 자체를 제외함
}

/// 클래스 등록 API 응답 (code, status, data)
struct ClassRegisterResponse: Codable {
    let code: Int
    let status: String
    let data: ClassRegisterResultDto?
}

/// 클래스 등록 결과 (생성/수정된 클래스 ID)
/// 스웨거(2026-09 기준)는 data가 classId 문자열 자체라고 명시하지만, 과거엔 {"classId": "..."} 객체였으므로 두 형태 모두 허용
struct ClassRegisterResultDto: Codable {
    let classId: String

    private enum CodingKeys: String, CodingKey { case classId }

    init(classId: String) { self.classId = classId }

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let id = try? single.decode(String.self) {
            classId = id
            return
        }
        let c = try decoder.container(keyedBy: CodingKeys.self)
        classId = try c.decode(String.self, forKey: .classId)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(classId, forKey: .classId)
    }
}

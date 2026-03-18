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
    
    var id: String { scheduleId ?? localId ?? "\(name)-\(dates.joined())-\(startTime.timeString)" }
    
    enum CodingKeys: String, CodingKey {
        case scheduleId, dates, startTime, endTime, minCapacity, maxCapacity, name
    }
    
    init(scheduleId: String?, localId: String? = nil, dates: [String], startTime: LocalTimeDTO, endTime: LocalTimeDTO, minCapacity: Int, maxCapacity: Int, name: String) {
        self.scheduleId = scheduleId
        self.localId = localId
        self.dates = dates
        self.startTime = startTime
        self.endTime = endTime
        self.minCapacity = minCapacity
        self.maxCapacity = maxCapacity
        self.name = name
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
    let dates: [String]
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
}

/// 클래스 등록 API 응답 (code, status, data)
struct ClassRegisterResponse: Codable {
    let code: Int
    let status: String
    let data: String?
}

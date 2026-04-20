//
//  ClassRegisterContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/25/26.
//

import SwiftUI
import Foundation
import UIKit

// MARK: - Intent
enum ClassRegisterIntent {
    /// 운영 방식 선택 (oneDay, regular, season, workshop)
    case selectClassType(String)
    
    // Step 1: 수련 설명
    /// 수련 설명 업데이트 (제목, 설명)
    case updateExplanation(name: String, description: String)
    /// 특징(수련 장점) 토글 선택 (최대 3개)
    case toggleFeature(String)
    
    // Step 2: 유형 선택
    /// 전문 수련 유형 토글 (최대 13개)
    case toggleType(String)
    /// 수련 카테고리 토글 (최대 9개)
    case toggleCategory(String)
    /// 이용 대상 토글 (최대 7개)
    case toggleTarget(String)
    
    // Step 3: 수련 정보 (스케줄)
    /// 스케줄 추가
    case addSchedule(NewScheduleDTO)
    /// 스케줄 삭제
    case removeSchedule(String)
    
    // Step 4: 수련 장소
    /// 요가원(수련 장소) 선택
    case selectCenter(String?)
    
    // Step 5: 이미지 등록
    /// 수련원 이미지 추가 (최대 20장, 추가 시 isLoading: true)
    case addClassImages([Data])
    /// 특정 이미지 로딩 완료 (placeholder → 실제 이미지 표시)
    case setClassImageLoaded(String)
    /// Presigned 업로드 완료 시 imageKey 저장
    case setClassImageUploaded(id: String, imageKey: String)
    /// 수련원 이미지 삭제
    case removeClassImage(String)
    /// 수련원 이미지 순서 변경
    case reorderClassImages([String])
    
    // Step 6: 가격 설정
    /// 1회 수업 금액 (원)
    case setPricePerSession(String)
    /// 할인 방식: "rate" 정률 / "amount" 정액
    case setDiscountMethod(String?)
    /// 할인률 (%)
    case setDiscountRate(String)
    /// 할인액 (원)
    case setDiscountAmount(String)
    /// 환불 기준 행 수정 (피그마 기준 3칸 고정, id로 구분)
    case updateRefundRule(id: String, hoursBefore: Int, percent: Int)
    /// 예약 시 안내사항 (최대 3000자)
    case setReservationNotice(String)
    
    // 정규 수련: 금액 플랜
    case addRegularPricePlan(RegularPricePlan)
    case removeRegularPricePlan(String)

    // 정규 수련: 휴무 정보
    /// 고정 휴무 있음 / 없음 (없으면 주간·공휴일 UI 숨김)
    case setRegularHasFixedHolidays(Bool)
    /// 주간 휴무 요일 토글 (1=월 … 7=일, 포함 시 해당 요일 휴무)
    case toggleRegularWeeklyOffWeekday(Int)
    /// 공휴일 휴무 칩 토글
    case toggleRegularPublicHolidayOff(String)
    /// 공휴일 전체 휴무 프리셋
    case applyRegularPublicHolidayPresetAll
}


// MARK: - State
struct ClassRegisterState: Equatable {
    /// 선택된 수련 타입 ID (oneDay, regular, season, workshop)
    var selectedClassTypeId: String?
    
    // Step 1: 수련 설명
    /// 클래스 이름 (API: name, 최대 22자)
    var name: String = ""
    /// 클래스 설명 (API: description, 최대 3000자)
    var description: String = ""
    /// 선택된 특징 ID (API: featureIds, 최대 3개)
    var featureIds: Set<String> = []
    
    /// 코드 목록 (features 등)
    var features: [CodeInfoDTO] = []
    var isLoadingCodeList: Bool = false
    var codeListError: String?
    
    // Step 2: 유형 선택
    /// 전문 수련 유형 목록 (CodeListDto > categories > type)
    var types: [CodeInfoDTO] = []
    /// 수련 카테고리 목록 (CodeListDto > categories > category)
    var categories: [CodeInfoDTO] = []
    /// 이용 대상 목록 (CodeListDto > categories > target)
    var targets: [CodeInfoDTO] = []
    /// 편의시설 목록 (CodeListDto > amenities > amenity, facility)
    var amenities: AmenityCodeListDTO?
    /// 선택된 전문 수련 유형 ID (최대 13개)
    var typeIds: Set<String> = []
    /// 선택된 수련 카테고리 ID (최대 9개)
    var categoryIds: Set<String> = []
    /// 선택된 이용 대상 ID (최대 7개)
    var targetIds: Set<String> = []
    
    // Step 3: 수련 정보 (스케줄)
    /// 등록된 스케줄 목록 (NewClassDto.schedules)
    var schedules: [NewScheduleDTO] = []
    
    // Step 4: 수련 장소
    /// 등록된 요가원 목록 (GET /api/center)
    var centers: [CenterBaseDTO] = []
    /// 선택된 요가원 ID (2b에서 선택 시 다음 단계 활성화)
    var selectedCenterId: String?
    var isLoadingCenters: Bool = false
    var centersError: String?
    
    // Step 5: 이미지 등록
    /// 수련원 이미지 (최대 20장, 드래그로 순서 변경)
    var classImages: [ClassRegisterImageItem] = []
    
    // Step 6: 가격 설정
    /// 1회 수업 금액 (원) - 입력 문자열
    var pricePerSession: String = ""
    /// 할인 방식: "rate" 정률 / "amount" 정액 / nil 미선택
    var discountMethod: String? = nil
    /// 할인률 (%) - 정률 선택 시
    var discountRate: String = ""
    /// 할인액 (원) - 정액 선택 시
    var discountAmount: String = ""
    /// 환불 기준 3칸 고정 (수련 시작 N시간 전 N% 환불)
    var refundRules: [RefundRuleRow] = [
        RefundRuleRow(id: "refund_0", hoursBefore: 0, percent: 0),
        RefundRuleRow(id: "refund_1", hoursBefore: 0, percent: 0),
        RefundRuleRow(id: "refund_2", hoursBefore: 0, percent: 0)
    ]
    /// 예약 시 안내사항 (최대 3000자)
    var reservationNotice: String = ""
    
    // MARK: 정규 수련 — 금액 플랜 목록 (기간권/회차권)
    var regularPricePlans: [RegularPricePlan] = []

    // MARK: 정규 수련 — 휴무 정보
    /// true: 휴무일 있음(상세 선택 표시), false: 없음
    var regularHasFixedHolidays: Bool = true
    /// 1=월 … 7=일. 포함된 요일이 휴무
    var regularWeeklyOffWeekdays: Set<Int> = []
    /// 휴무로 지정한 공휴일 id (`RegularPublicHoliday.rawValue`)
    var regularPublicHolidayOffIds: Set<String> = RegularPublicHoliday.allHolidayIds
}

// MARK: - Container
@MainActor
class ClassRegisterContainer: ObservableObject {
    @Published private(set) var state = ClassRegisterState()
    
    func handleIntent(_ intent: ClassRegisterIntent) {
        switch intent {
        case .selectClassType(let typeId):
            state.selectedClassTypeId = typeId
            
        case .updateExplanation(let name, let description):
            state.name = String(name.prefix(22))
            state.description = String(description.prefix(3000))
            
        case .toggleFeature(let featureId):
            if state.featureIds.contains(featureId) {
                state.featureIds.remove(featureId)
            } else if state.featureIds.count < 3 {
                state.featureIds.insert(featureId)
            }
            
        case .toggleType(let typeId):
            if state.typeIds.contains(typeId) {
                state.typeIds.remove(typeId)
            } else if state.typeIds.count < 13 {
                state.typeIds.insert(typeId)
            }
            
        case .toggleCategory(let categoryId):
            if state.categoryIds.contains(categoryId) {
                state.categoryIds.remove(categoryId)
            } else if state.categoryIds.count < 9 {
                state.categoryIds.insert(categoryId)
            }
            
        case .toggleTarget(let targetId):
            if state.targetIds.contains(targetId) {
                state.targetIds.remove(targetId)
            } else if state.targetIds.count < 7 {
                state.targetIds.insert(targetId)
            }
            
        case .addSchedule(let schedule):
            state.schedules.append(schedule)
            
        case .removeSchedule(let id):
            state.schedules.removeAll { $0.id == id }
            
        case .selectCenter(let centerId):
            state.selectedCenterId = centerId
            
        case .addClassImages(let dataList):
            var newImages = state.classImages
            for data in dataList where newImages.count < 20 {
                newImages.append(ClassRegisterImageItem(id: UUID().uuidString, imageData: data, isLoading: true))
            }
            objectWillChange.send()
            state.classImages = newImages
        case .setClassImageLoaded(let id):
            guard let index = state.classImages.firstIndex(where: { $0.id == id }) else { return }
            var updated = state.classImages[index]
            updated.isLoading = false
            state.classImages[index] = updated
            objectWillChange.send()
        case .setClassImageUploaded(let id, let imageKey):
            guard let index = state.classImages.firstIndex(where: { $0.id == id }) else { return }
            var updated = state.classImages[index]
            updated.isLoading = false
            updated.imageKey = imageKey
            state.classImages[index] = updated
            objectWillChange.send()
        case .removeClassImage(let id):
            objectWillChange.send()
            state.classImages = state.classImages.filter { $0.id != id }
        case .reorderClassImages(let orderedIds):
            let orderMap = Dictionary(uniqueKeysWithValues: orderedIds.enumerated().map { ($1, $0) })
            objectWillChange.send()
            state.classImages = state.classImages.sorted { (orderMap[$0.id] ?? 0) < (orderMap[$1.id] ?? 0) }
        case .setPricePerSession(let value):
            objectWillChange.send()
            state.pricePerSession = value
        case .setDiscountMethod(let value):
            objectWillChange.send()
            state.discountMethod = value
        case .setDiscountRate(let value):
            objectWillChange.send()
            state.discountRate = value
        case .setDiscountAmount(let value):
            objectWillChange.send()
            state.discountAmount = value
        case .updateRefundRule(let id, let hoursBefore, let percent):
            if let idx = state.refundRules.firstIndex(where: { $0.id == id }) {
                objectWillChange.send()
                state.refundRules[idx].hoursBefore = hoursBefore
                state.refundRules[idx].percent = percent
            }
        case .setReservationNotice(let value):
            objectWillChange.send()
            state.reservationNotice = String(value.prefix(3000))
            
        case .addRegularPricePlan(let plan):
            state.regularPricePlans.append(plan)

        case .removeRegularPricePlan(let id):
            state.regularPricePlans.removeAll { $0.id == id }

        case .setRegularHasFixedHolidays(let value):
            objectWillChange.send()
            state.regularHasFixedHolidays = value
            
        case .toggleRegularWeeklyOffWeekday(let weekday):
            guard (1...7).contains(weekday) else { return }
            objectWillChange.send()
            if state.regularWeeklyOffWeekdays.contains(weekday) {
                state.regularWeeklyOffWeekdays.remove(weekday)
            } else {
                state.regularWeeklyOffWeekdays.insert(weekday)
            }
            
        case .toggleRegularPublicHolidayOff(let id):
            objectWillChange.send()
            if state.regularPublicHolidayOffIds.contains(id) {
                state.regularPublicHolidayOffIds.remove(id)
            } else {
                state.regularPublicHolidayOffIds.insert(id)
            }
            
        case .applyRegularPublicHolidayPresetAll:
            objectWillChange.send()
            state.regularPublicHolidayOffIds = RegularPublicHoliday.allHolidayIds
        }
    }
    
    /// 이미지 1장 Presigned 발급 → PUT 업로드 → imageKey 저장
    func uploadClassImage(itemId: String, imageData: Data) async {
        guard let image = UIImage(data: imageData) else {
            handleIntent(.setClassImageLoaded(itemId))
            return
        }
        let width = Int(image.size.width * image.scale)
        let height = Int(image.size.height * image.scale)
        let fileSize = imageData.count
        let fileName = "\(UUID().uuidString).jpg"
        let contentType = "image/jpeg"
        let dto = ImageUploadDto(
            type: "class",
            files: [ImageUploadInfoDto(fileName: fileName, contentType: contentType, width: width, height: height, fileSize: fileSize)]
        )
        do {
            let response = try await APIService.shared.postImagePresign(body: dto)
            guard let first = response.files.first else {
                handleIntent(.setClassImageLoaded(itemId))
                return
            }
            try await APIService.shared.uploadImageToPresignedUrl(data: imageData, presignedUrl: first.presignedUrl, contentType: first.contentType)
            await MainActor.run { handleIntent(.setClassImageUploaded(id: itemId, imageKey: first.imageKey)) }
        } catch {
            await MainActor.run { handleIntent(.setClassImageLoaded(itemId)) }
        }
    }
    
    /// 요가원 목록 로드 (GET /api/center)
    func loadCenterList() {
        state.isLoadingCenters = true
        state.centersError = nil
        
        Task {
            do {
                let list = try await APIService.shared.getCenterList()
                await MainActor.run {
                    self.state.centers = list
                    self.state.isLoadingCenters = false
                }
            } catch {
                await MainActor.run {
                    self.state.centersError = error.localizedDescription
                    self.state.centers = []
                    self.state.isLoadingCenters = false
                }
            }
        }
    }
    
    /// 코드 목록 로드 (features)
    func loadCodeList() {
        state.isLoadingCodeList = true
        state.codeListError = nil
        
        Task {
            do {
                let response = try await APIService.shared.getCodeList()
                await MainActor.run {
                    self.state.features = response.data.features
                    self.state.types = response.data.categories.type
                    self.state.categories = response.data.categories.category
                    self.state.targets = response.data.categories.target
                    self.state.amenities = response.data.amenities
                    self.state.isLoadingCodeList = false
                }
            } catch {
                await MainActor.run {
                    self.state.codeListError = error.localizedDescription
                    self.state.isLoadingCodeList = false
                }
            }
        }
    }
    
    /// state 기준으로 클래스 등록 요청 DTO 생성 후 POST /api/class 호출
    func registerClass() async throws -> ClassRegisterResponse {
        let s = state
        let isRegular = s.selectedClassTypeId == "regular"
        let classType: String = isRegular ? "R" : "O"

        // MARK: 스케줄
        // 정규: dates 배열 내 날짜별로 dayOfWeek를 역산하여 요일당 1개 아이템으로 분리
        // 하루: dates 그대로, dayOfWeek 없음
        let schedules: [ClassRegisterScheduleItemDto]
        if isRegular {
            let cal = Calendar.current
            let dateFmt = DateFormatter(); dateFmt.dateFormat = "yyyy-MM-dd"
            schedules = s.schedules.flatMap { sched -> [ClassRegisterScheduleItemDto] in
                sched.dates.compactMap { dateStr -> ClassRegisterScheduleItemDto? in
                    guard let date = dateFmt.date(from: dateStr) else { return nil }
                    // Calendar weekday: 1=일,2=월...7=토 → App weekday: 1=월...7=일
                    let calWd = cal.component(.weekday, from: date)
                    let appWd = ((calWd - 2 + 7) % 7) + 1
                    return ClassRegisterScheduleItemDto(
                        scheduleId: sched.scheduleId,
                        dates: [dateStr],
                        dayOfWeek: appWd,
                        startTime: sched.startTime.timeString,
                        endTime: sched.endTime.timeString,
                        minCapacity: sched.minCapacity,
                        maxCapacity: sched.maxCapacity,
                        name: sched.name
                    )
                }
            }
        } else {
            schedules = s.schedules.map {
                ClassRegisterScheduleItemDto(
                    scheduleId: $0.scheduleId,
                    dates: $0.dates,
                    dayOfWeek: nil,
                    startTime: $0.startTime.timeString,
                    endTime: $0.endTime.timeString,
                    minCapacity: $0.minCapacity,
                    maxCapacity: $0.maxCapacity,
                    name: $0.name
                )
            }
        }

        // MARK: 공통 — 이미지·환불
        let imageKeys = s.classImages.compactMap(\.imageKey)
        let refundPolicies = s.refundRules.map {
            ClassRegisterRefundPolicyDto(hoursBeforeClass: $0.hoursBefore, refundRate: $0.percent)
        }

        // MARK: 공통 — 이름
        let registerName: String = {
            if isRegular {
                if let centerId = s.selectedCenterId,
                   let centerName = s.centers.first(where: { $0.centerId == centerId })?.name {
                    let trimmed = centerName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty { return String(trimmed.prefix(22)) }
                }
                let desc = s.description.trimmingCharacters(in: .whitespacesAndNewlines)
                if !desc.isEmpty { return String(desc.prefix(22)) }
            }
            return s.name
        }()

        // MARK: 원데이 전용 — 가격·할인
        let onedayPrice     = Int(s.pricePerSession.replacingOccurrences(of: ",", with: "")) ?? 0
        let discountPrice   = s.discountMethod == "amount" ? Int(s.discountAmount) : nil
        let discountRate    = s.discountMethod == "rate"   ? Int(s.discountRate)   : nil

        // MARK: 정규 전용 — 수강권(tickets)
        let tickets: [ClassRegisterTicketDto]? = isRegular ? s.regularPricePlans.map {
            ClassRegisterTicketDto(
                ticketId:      nil,
                ticketType:    $0.planType.rawValue,
                ticketName:    $0.ticketName,
                price:         $0.price,
                validMonths:   $0.planType == .period  ? $0.validMonths    : nil,
                weeklyCount:   $0.planType == .period  ? $0.weeklyCount    : nil,
                totalSessions: $0.planType == .session ? $0.totalSessions  : nil
            )
        } : nil

        // MARK: 정규 전용 — 휴무 정책
        let holidayPolicy: ClassRegisterHolidayPolicyDto? = {
            guard isRegular, s.regularHasFixedHolidays else { return nil }
            let weeklyOffDays = s.regularWeeklyOffWeekdays.isEmpty ? nil : Array(s.regularWeeklyOffWeekdays).sorted()

            // "설,추석 당일만 휴무" 프리셋 여부: 해당 IDs 집합과 일치하면 당일만 전송
            let isDayOnly = s.regularPublicHolidayOffIds == RegularPublicHoliday.seolChuseokOnlyIds
            let publicHolidays: [String]? = s.regularPublicHolidayOffIds.isEmpty ? nil :
                s.regularPublicHolidayOffIds.flatMap { id -> [String] in
                    guard let holiday = RegularPublicHoliday(rawValue: id) else { return [] }
                    if isDayOnly, let dayOnly = holiday.dayOnlyApiValue { return [dayOnly] }
                    return holiday.fullApiValues
                }

            guard weeklyOffDays != nil || publicHolidays != nil else { return nil }
            return ClassRegisterHolidayPolicyDto(weeklyOffDays: weeklyOffDays, publicHolidays: publicHolidays)
        }()

        // MARK: 정규 top-level price: 최소 수강권 금액 (없으면 0)
        let regularPrice = s.regularPricePlans.map(\.price).min() ?? 0

        let body = ClassRegisterRequestDto(
            type:          classType,
            classId:       nil,
            name:          registerName,
            description:   s.description.nilIfEmpty,
            centerId:      s.selectedCenterId,
            featureIds:    s.featureIds.isEmpty ? nil : Array(s.featureIds),
            schedules:     schedules,
            images:        imageKeys.isEmpty ? nil : imageKeys,
            price:         isRegular ? regularPrice : onedayPrice,
            categoryIds:   s.categoryIds.isEmpty ? nil : Array(s.categoryIds),
            policy:        ClassRegisterPolicyDto(
                discountPrice:   isRegular ? nil : discountPrice,
                discountRate:    isRegular ? nil : discountRate,
                reservationNote: s.reservationNotice.nilIfEmpty,
                refundPolicies:  refundPolicies.isEmpty ? nil : refundPolicies
            ),
            holidayPolicy: holidayPolicy,
            tickets:       tickets
        )
        return try await APIService.shared.postRegisterClass(body: body)
    }
}

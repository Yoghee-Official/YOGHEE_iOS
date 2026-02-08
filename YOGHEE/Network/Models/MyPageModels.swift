//
//  MyPageModels.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import Foundation

// MARK: - User Role
enum UserRole: String, Codable, Equatable {
    case yogini      // 요기니
    case instructor  // 지도자
    
    var displayName: String {
        switch self {
        case .yogini: return "요기니"
        case .instructor: return "지도자"
        }
    }
}

// MARK: - MyPage Response
struct MyPageResponse: Codable {
    let code: Int
    let status: String
    let data: MyPageDataDTO
}

// MARK: - MyPage Data
struct MyPageDataDTO: Codable, Equatable {
    // 요기니 전용
    let userProfile: UserProfileDTO?
    let weekClasses: WeekClassDTO?
    let favoriteClasses: [ClassDTO]?
    let favoriteCenters: [CenterDTO]?
    
    // 지도자 전용
    let leaderProfile: LeaderProfileDTO?
    let todayClasses: [YogaClassScheduleDTO]?
    
    // 공통
    let reservedClasses: [YogaClassScheduleDTO]?
}

// MARK: - User Profile (요기니)
struct UserProfileDTO: Codable, Equatable {
    let nickname: String?
    let profileImage: String?
    let totalClass: Int?
    let plannedClass: Int?
    let totalHour: String?
    let grade: String?
    let level: Int?
    let monthlyCategoryCount: Int?
    let monthlyCategory: String?
}

// MARK: - Leader Profile (지도자)
struct LeaderProfileDTO: Codable, Equatable {
    let nickname: String?
    let profileImage: String?
    let totalReview: Int?          // 총 리뷰 수
    let totalMyClass: Int?          // 총 수업 수
    let introduction: String?       // 소개
    let certificate: String?        // 자격증
    let popularCategory: String?    // 인기 카테고리
    let reservedCount: Int?         // 예약 수
}

struct WeekClassDTO: Codable, Equatable {
    let weekDay: [YogaClassScheduleDTO]?
    let weekEnd: [YogaClassScheduleDTO]?
}

struct YogaClassScheduleDTO: Codable, Equatable {
    let classId: String
    let className: String
    let day: String
    let dayOfWeek: Int
    let thumbnailUrl: String
    let address: String
    let attendance: Int
    let isPast: Bool
    let categories: [String]?
}

//struct FavoriteOneDayClassDTO: Codable, Equatable {
//    let classId: String
//    let className: String
//    let image: String
//    let masterId: String?
//    let masterName: String?
//    let review: Int?
//    let rating: Double?
//}
//
//struct FavoriteRegularClassDTO: Codable, Equatable {
//    let classId: String
//    let className: String
//    let image: String
//    let address: String?
//    let favoriteCount: Int?
//}

// MARK: - MyPage Section Type
enum MyPageSectionType: String {
    // 공통
    case profile
    case detailContents
    
    // 요기니 전용
    case weekClasses
    case favoriteClasses
    case favoriteCenters
    
    // 지도자 전용
    case todayClasses
    
    // 공통 (의미가 다름: 요기니 = 예약한 수업, 지도자 = 예약된 수업)
    case reservedClasses
    
//    var displayName: String {
//        switch self {
//        case .profile: return "프로필"
//        case .weekClasses: return "이번주 참여 수련"
//        case .todayClasses: return "오늘 지도 수련 목록"
//        case .reservedClasses: return "예약 수련"
//        case .favoriteClasses: return "찜한 수련"
//        case .favoriteCenters: return "찜한 요가원"
//        case .detailContents: return "세부 항목"
//        }
//    }
}

// MARK: - Section Configuration
struct MyPageSectionConfiguration {
    let role: UserRole
    
    /// Role별 노출되는 섹션들 (한눈에 관리!)
    var availableSections: [MyPageSectionType] {
        switch role {
        case .yogini:
            return [
                .profile,              // 요기니 프로필
                .weekClasses,          // 이번주 수련
                .reservedClasses,      // 예약한 수련
                .favoriteClasses,      // 찜한 수련
                .favoriteCenters,      // 찜한 요가원
                .detailContents        // 세부 항목
            ]
            
        case .instructor:
            return [
                .profile,              // 지도자 프로필
                .todayClasses,         // 오늘의 수업
                .reservedClasses,      // 예약된 수업
                .detailContents        // 세부 항목
            ]
        }
    }
    
    /// 특정 섹션 타입이 현재 Role에서 보여져야 하는지 확인
    func isVisible(_ sectionType: MyPageSectionType) -> Bool {
        return availableSections.contains(sectionType)
    }
}

// MARK: - MyPage Section
enum MyPageSection: Identifiable {
    // 공통
    case profile
    case detailContents
    
    // 요기니 전용
    case weekClasses(weekDay: [YogaClassScheduleDTO]?, weekEnd: [YogaClassScheduleDTO]?)
    case favoriteClasses(items: [ClassDTO])
    case favoriteCenters(items: [CenterDTO])
    
    // 지도자 전용
    case todayClasses(items: [YogaClassScheduleDTO])
    
    // 공통 (의미가 다름)
    case reservedClasses(items: [YogaClassScheduleDTO])
    
    // Title 타입 정의
    enum TitleType {
        case toggle  // 지도자/요기니 토글
        case moreButton  // 목록 더보기 버튼
        case none  // 헤더 없음
    }
    
    var id: String {
        switch self {
        case .profile: return "profile"
        case .weekClasses: return "weekClasses"
        case .todayClasses: return "todayClasses"
        case .reservedClasses: return "reservedClasses"
        case .favoriteClasses: return "favoriteClasses"
        case .favoriteCenters: return "favoriteCenters"
        case .detailContents: return "detailContents"
        }
    }
    
    var title: String {
        switch self {
        case .profile: return ""
        case .weekClasses: return "이번주 참여 수련 목록"
        case .todayClasses: return "오늘 지도 수련 목록"
        case .reservedClasses: return "예약한 수련 미리보기"
        case .favoriteClasses: return "찜한 수련 목록"
        case .favoriteCenters: return "찜한 요가원 목록"
        case .detailContents: return "세부 항목"
        }
    }
    
    var titleType: TitleType {
        switch self {
        case .weekClasses, .todayClasses:
            return .toggle
        case .reservedClasses, .favoriteClasses, .favoriteCenters:
            return .moreButton
        case .profile, .detailContents:
            return .none
        }
    }
    
    /// 각 Section의 타입 반환
    var sectionType: MyPageSectionType {
        switch self {
        case .profile: return .profile
        case .weekClasses: return .weekClasses
        case .todayClasses: return .todayClasses
        case .reservedClasses: return .reservedClasses
        case .favoriteClasses: return .favoriteClasses
        case .favoriteCenters: return .favoriteCenters
        case .detailContents: return .detailContents
        }
    }
}

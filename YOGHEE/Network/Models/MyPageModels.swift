//
//  MyPageModels.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import Foundation

// MARK: - MyPage Response
struct MyPageResponse: Codable {
    let code: Int
    let status: String
    let data: MyPageDataDTO
}

// MARK: - MyPage Data
struct MyPageDataDTO: Codable, Equatable {
    let userProfile: UserProfileDTO?
    let reservedClasses: [YogaClassScheduleDTO]?
    let weekClasses: WeekClassDTO?
    let favoriteClasses: [ClassDTO]?
    let favoriteCenters: [CenterDTO]?
}

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

// MARK: - MyPage Section
enum MyPageSection: Identifiable {
    case profile
    case weekClasses(weekDay: [YogaClassScheduleDTO]?, weekEnd: [YogaClassScheduleDTO]?)
    case reservedClasses(items: [YogaClassScheduleDTO])
    case favoriteClasses(items: [ClassDTO])
    case favoriteCenters(items: [CenterDTO])
    case detailContents
    
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
        case .reservedClasses: return "reservedClasses"
        case .favoriteClasses: return "favoriteClasses"
        case .favoriteCenters: return "favoriteCenters"
        case .detailContents: return "detailContents"
        }
    }
    
    var title: String {
        switch self {
        case .profile: return ""
        case .weekClasses: return "이번주 수련 목록"
        case .reservedClasses: return "예약한 수련 미리보기"
        case .favoriteClasses: return "찜한 수련 목록"
        case .favoriteCenters: return "찜한 요가원 목록"
        case .detailContents: return "세부 항목"
        }
    }
    
    var titleType: TitleType {
        switch self {
        case .weekClasses:
            return .toggle
        case .reservedClasses, .favoriteClasses, .favoriteCenters:
            return .moreButton
        case .profile, .detailContents:
            return .none
        }
    }
}

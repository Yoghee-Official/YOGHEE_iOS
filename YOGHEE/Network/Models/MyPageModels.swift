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
    let favoriteRegularClasses: [FavoriteRegularClassDTO]?
    let favoriteOneDayClasses: [FavoriteOneDayClassDTO]?
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
}

struct FavoriteOneDayClassDTO: Codable, Equatable {
    let classId: String
    let className: String
    let image: String
    let masterId: String?
    let masterName: String?
    let review: Int?
    let rating: Double?
}

struct FavoriteRegularClassDTO: Codable, Equatable {
    let classId: String
    let className: String
    let image: String
    let address: String?
    let favoriteCount: Int?
}

// MARK: - MyPage Section
enum MyPageSection: Identifiable {
    case profile
    case weekClasses(weekDay: [YogaClassScheduleDTO]?, weekEnd: [YogaClassScheduleDTO]?)
    case reservedClasses(items: [YogaClassScheduleDTO])
    case favoriteOneDayClasses(items: [FavoriteOneDayClassDTO])
    case favoriteRegularClasses(items: [FavoriteRegularClassDTO])
    case detailContents
    
    var id: String {
        switch self {
        case .profile: return "profile"
        case .weekClasses: return "weekClasses"
        case .reservedClasses: return "reservedClasses"
        case .favoriteOneDayClasses: return "favoriteOneDayClasses"
        case .favoriteRegularClasses: return "favoriteRegularClasses"
        case .detailContents: return "detailContents"
        }
    }
    
    var title: String {
        switch self {
        case .profile: return ""
        case .weekClasses: return "이번 주 수업"
        case .reservedClasses: return "예약된 수업"
        case .favoriteOneDayClasses: return "찜한 하루 수업"
        case .favoriteRegularClasses: return "찜한 정규 수업"
        case .detailContents: return ""
        }
    }
}

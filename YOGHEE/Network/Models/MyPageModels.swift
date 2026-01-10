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
    let totalHours: String?
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
    case thisWeekClassList
    case reservedClasses
    case favoriteOneDayClasses
    case favoriteRegularClasses
    
    var id: String {
        switch self {
        case .profile: return "profile"
        case .thisWeekClassList: return "thisWeekClassList"
        case .reservedClasses: return "reservedClasses"
        case .favoriteOneDayClasses: return "favoriteOneDayClasses"
        case .favoriteRegularClasses: return "favoriteRegularClasses"
        }
    }
}

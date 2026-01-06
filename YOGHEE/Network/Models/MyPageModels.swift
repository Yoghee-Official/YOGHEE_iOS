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
    let nickname: String
    let profileImage: String?
    let accumulatedClass: Int
    let plannedClass: Int
    let accumulatedHours: String
    let grade: String
    let level: Int
    let monthlyCategoryCount: Int
    let monthlyCategory: String?
    let reservedClasses: [YogaClassScheduleDTO]?
    let weekDayClasses: [YogaClassScheduleDTO]?
    let weekEndClasses: [YogaClassScheduleDTO]?
    let favoriteRegularClasses: [FavoriteRegularClassDTO]?
    let favoriteOneDayClasses: [FavoriteOneDayClassDTO]?
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

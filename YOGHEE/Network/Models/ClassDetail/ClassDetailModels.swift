//
//  ClassDetailModels.swift
//  YOGHEE
//

import Foundation

// MARK: - Response
struct ClassDetailResponse: Codable {
    let code: Int
    let status: String
    let data: YogaClassDetailDTO
}

// MARK: - DTO
struct YogaClassDetailDTO: Codable {
    let classId: String
    let type: String
    let name: String
    let description: String?
    let price: Int
    let images: [String]
    let thumbnail: String?
    let categories: [CategoryInfo]
    let features: [FeatureInfo]
    let favoriteCount: Int
    let isFavorite: Bool
    let reviewCount: Int
    let rating: Double
    let recentReviews: [YogaReviewDTO]
    let policy: PolicyInfo?
    let schedules: [ScheduleInfo]
    let tickets: [TicketInfo]
    let center: CenterInfo?
}

struct CategoryInfo: Codable {
    let categoryId: String
    let name: String
}

struct FeatureInfo: Codable {
    let featureId: Int
    let code: String
    let description: String
}

struct ScheduleInfo: Codable {
    let scheduleId: String
    let dayOfWeek: Int?
    let specificDate: String?
    let startTime: String?
    let endTime: String?
    let minCapacity: Int?
    let maxCapacity: Int?
    let content: String?
}

struct TicketInfo: Codable {
    let ticketId: String
    let ticketType: String
    let price: Int
    let validMonths: Int?
    let weeklyCount: Int?
    let totalSessions: Int?
}

struct CenterInfo: Codable {
    let centerId: String
    let name: String
    let description: String?
    let thumbnail: String?
    let fullAddress: String?
    let roadAddress: String?
    let depth1: String?
    let depth2: String?
    let depth3: String?
    let addressDetail: String?
    let latitude: Double?
    let longitude: Double?
    let amenities: [String]
}

struct PolicyInfo: Codable {
    let discountPrice: Int?
    let discountRate: Int?
    let reservationNote: String?
    let refundPolicies: [RefundInfo]
}

struct RefundInfo: Codable {
    let hoursBeforeClass: Int
    let refundRate: Int
}

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
    let trainingTypes: [CategoryInfo]
    let trainingTargets: [CategoryInfo]
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
    let masterInfo: MasterInfo?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        classId       = try c.decode(String.self,          forKey: .classId)
        type          = try c.decode(String.self,          forKey: .type)
        name          = try c.decode(String.self,          forKey: .name)
        description   = try c.decodeIfPresent(String.self, forKey: .description)
        price         = try c.decode(Int.self,             forKey: .price)
        images        = try c.decodeIfPresent([String].self,       forKey: .images)        ?? []
        thumbnail     = try c.decodeIfPresent(String.self,         forKey: .thumbnail)
        categories    = try c.decodeIfPresent([CategoryInfo].self, forKey: .categories)    ?? []
        trainingTypes = try c.decodeIfPresent([CategoryInfo].self, forKey: .trainingTypes) ?? []
        trainingTargets = try c.decodeIfPresent([CategoryInfo].self, forKey: .trainingTargets) ?? []
        features      = try c.decodeIfPresent([FeatureInfo].self,  forKey: .features)      ?? []
        favoriteCount = try c.decode(Int.self,             forKey: .favoriteCount)
        isFavorite    = try c.decode(Bool.self,            forKey: .isFavorite)
        reviewCount   = try c.decode(Int.self,             forKey: .reviewCount)
        rating        = try c.decode(Double.self,          forKey: .rating)
        recentReviews = try c.decodeIfPresent([YogaReviewDTO].self, forKey: .recentReviews) ?? []
        policy        = try c.decodeIfPresent(PolicyInfo.self,     forKey: .policy)
        schedules     = try c.decodeIfPresent([ScheduleInfo].self, forKey: .schedules)     ?? []
        tickets       = try c.decodeIfPresent([TicketInfo].self,   forKey: .tickets)       ?? []
        center        = try c.decodeIfPresent(CenterInfo.self,     forKey: .center)
        masterInfo    = try c.decodeIfPresent(MasterInfo.self,     forKey: .masterInfo)
    }

    init(classId: String, type: String, name: String, description: String?,
         price: Int, images: [String], thumbnail: String?,
         categories: [CategoryInfo], features: [FeatureInfo],
         favoriteCount: Int, isFavorite: Bool, reviewCount: Int, rating: Double,
         recentReviews: [YogaReviewDTO], policy: PolicyInfo?,
         schedules: [ScheduleInfo], tickets: [TicketInfo], center: CenterInfo?,
         trainingTypes: [CategoryInfo] = [], trainingTargets: [CategoryInfo] = [],
         masterInfo: MasterInfo? = nil) {
        self.classId        = classId
        self.type           = type
        self.name           = name
        self.description    = description
        self.price          = price
        self.images         = images
        self.thumbnail      = thumbnail
        self.categories     = categories
        self.trainingTypes  = trainingTypes
        self.trainingTargets = trainingTargets
        self.features       = features
        self.favoriteCount  = favoriteCount
        self.isFavorite     = isFavorite
        self.reviewCount    = reviewCount
        self.rating         = rating
        self.recentReviews  = recentReviews
        self.policy         = policy
        self.schedules      = schedules
        self.tickets        = tickets
        self.center         = center
        self.masterInfo     = masterInfo
    }
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

struct MasterInfo: Codable {
    let nickname: String?
    let profileImage: String?
    let introduction: String?
    let career: Int?
    let certificate: String?
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

// MARK: - Review List
struct ReviewPageResponse: Codable {
    let code: Int
    let status: String
    let data: ReviewPageDTO
}

struct ReviewPageDTO: Codable {
    let reviews: [YogaReviewDTO]
    let page: Int
    let totalPages: Int
    let totalCount: Int
    let hasNext: Bool
}

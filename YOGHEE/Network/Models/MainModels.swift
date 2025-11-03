//
//  MainModels.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/12/25.
//

import Foundation

// Temp
typealias TodayClass = YogaClass
typealias InterestedClass = YogaClass
typealias CustomizedClass = YogaClass
typealias HotClass = YogaClass

// MARK: - Main Response
struct MainResponse: Codable {
    let code: Int
    let status: String
    let data: MainData
}

// MARK: - Main Data
struct MainData: Codable {
    let todayClass: [YogaClass]
    let imageBanner: [YogaClass]
    let interestedClass: [YogaClass]?
    let interestedCenter: [YogaCenter]?
    let top10Class: [YogaClass]?
    let top10Center: [YogaCenter]?
    let newReview: [Review]
    let yogaCategory: [YogaCategory]
    let layoutOrder: [LayoutOrder]
}

// MARK: - Yoga Class
struct YogaClass: Codable {
    // 필수 필드 (API에서 항상 제공)
    let classId: String
    let className: String
    let type: String
    let address: String
    let description: String
    let thumbnail: String
    let price: Int
    let capacity: Int
    let latitude: Double
    let longitude: Double
    
    // 옵셔널 필드 (API에 따라 제공되지 않을 수 있음)
    let masterId: String?
    let masterName: String?
    let review: Int?
    let newMember: Int?
    let rating: Double?
    let scheduleId: String?
    let startTime: String?
    let endTime: String?
}

// MARK: - Yoga Center
struct YogaCenter: Codable {
    let centerId: String
    let address: String
    let name: String
    let thumbnail: String
    let favoriteCount: Int
}

// MARK: - Review
struct Review: Codable {
    let reviewId: String
    let userUuid: String
    let thumbnail: String
    let content: String
    let rating: Int
    let createdAt: String
}

// MARK: - Yoga Category
struct YogaCategory: Codable {
    let categoryId: String
    let name: String
    let description: String
    let mainDisplay: String?
    let type: String?
}

// MARK: - Layout Order
struct LayoutOrder: Codable {
    let order: String
    let type: String
    let key: String
    let text: String?
}









// MARK: - Layout Section Type
enum LayoutSectionType: String, CaseIterable {
    case todayClass = "todayClass"
    case recommendClass = "recommendClass"
    case interestedClass = "interstedClass"  // API 오타 반영
    case interestedCenter = "interstedCenter" // API 오타 반영
    case yogaCategory = "yogaCategory"
    case top10Class = "top10Class"
    case top10Center = "top10Center"
    case newReview = "newReview"
    
    // Legacy aliases
    static let customizedClass: LayoutSectionType = .interestedClass
    static let hotClass: LayoutSectionType = .top10Class
    
    var defaultTitle: String {
        switch self {
        case .todayClass:
            return ""
        case .recommendClass:
            return "추천 랭킹"
        case .interestedClass, .interestedCenter:
            return "관심있게 보는 수련"
        case .yogaCategory:
            return "요가 카테고리"
        case .top10Class, .top10Center:
            return "BEST 수련"
        case .newReview:
            return "리뷰 둘러보기"
        }
    }
}

// MARK: - Home Section
struct HomeSection: Identifiable {
    let id = UUID()
    let type: LayoutSectionType
    let title: String
    let items: [any HomeSectionItem]
    
    init(type: LayoutSectionType, title: String? = nil, items: [any HomeSectionItem]) {
        self.type = type
        self.title = title ?? type.defaultTitle
        self.items = items
    }
}

// MARK: - Home Section Item Protocol
protocol HomeSectionItem {
    var id: String { get }
    var title: String { get }
    var imageURL: String { get }
}

// MARK: - Extensions for Protocol Conformance
extension YogaClass: HomeSectionItem {
    var id: String { classId }
    var title: String { className }
    var imageURL: String { thumbnail }
}

extension YogaCenter: HomeSectionItem {
    var id: String { centerId }
    var title: String { name }
    var imageURL: String { thumbnail }
}

extension Review: HomeSectionItem {
    var id: String { reviewId }
    var title: String { content }
    var imageURL: String { thumbnail }
}

extension YogaCategory: HomeSectionItem {
    var id: String { categoryId }
    var title: String { name }
    var imageURL: String { "" } // 카테고리는 이미지가 없으므로 빈 문자열
}

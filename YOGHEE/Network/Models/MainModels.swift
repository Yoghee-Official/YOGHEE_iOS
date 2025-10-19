//
//  MainModels.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/12/25.
//

import Foundation

// MARK: - Main Response
struct MainResponse: Codable {
    let code: Int
    let status: String
    let data: MainData
}

// MARK: - Main Data
struct MainData: Codable {
    let todayClass: [YogaClass]
    let recommendClass: [YogaClass]
    let customizedClass: [CustomizedClass]
    let hotClass: [HotClass]
    let newReview: [Review]
    let yogaCategory: [YogaCategory]
    let layoutOrder: [String]
}

// MARK: - Yoga Class
struct YogaClass: Codable {
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
}

// MARK: - Customized Class
struct CustomizedClass: Codable {
    let classId: String
    let className: String
    let thumbnail: String
    let masterId: String
    let review: Int
    let rating: Double
}

// MARK: - Hot Class
struct HotClass: Codable {
    let classId: String
    let className: String
    let thumbnail: String
    let masterId: String
    let review: Int
    let rating: Double
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
}









// MARK: - Layout Section Type
enum LayoutSectionType: String, CaseIterable {
    case todayClass = "todayClass"
    case recommendClass = "recommendClass"
    case customizedClass = "customizedClass"
    case category = "category"
    case hotClass = "hotClass"
    case newReview = "newReview"
    
    var title: String {
        switch self {
        case .todayClass:
            return "오늘의 수업"
        case .recommendClass:
            return "추천 랭킹"
        case .customizedClass:
            return "관심있게 보는 요가 수련"
        case .category:
            return "요가 카테고리"
        case .hotClass:
            return "요가 수련 TOP 10"
        case .newReview:
            return "최신 리뷰"
        }
    }
}

// MARK: - Home Section
struct HomeSection: Identifiable {
    let id = UUID()
    let type: LayoutSectionType
    let title: String
    let items: [any HomeSectionItem]
    
    init(type: LayoutSectionType, items: [any HomeSectionItem]) {
        self.type = type
        self.title = type.title
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

extension CustomizedClass: HomeSectionItem {
    var id: String { classId }
    var title: String { className }
    var imageURL: String { thumbnail }
}

extension HotClass: HomeSectionItem {
    var id: String { classId }
    var title: String { className }
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

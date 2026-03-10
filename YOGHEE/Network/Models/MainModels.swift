//
//  MainModels.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/12/25.
//

import Foundation

// MARK: - Class Type
enum ClassType: String, Codable, CaseIterable, Equatable {
    case oneDay = "O"
    case regular = "R"
    
    var toggleTitle: String {
        switch self {
        case .oneDay: return "하루수련"
        case .regular: return "정규수련"
        }
    }
    
    var moduleTitle: String {
        switch self {
        case .oneDay: return "취향탐색"
        case .regular: return "위치탐색"
        }
    }
}

// MARK: - Main Response
struct MainResponse: Codable {
    let code: Int
    let status: String
    let data: MainDataDTO
}

// MARK: - Main Data
struct MainDataDTO: Codable {
    let todayClass: [TodayClassDTO]
    let imageBanner: [MainBannerClassDTO]
    let interestedClass: [ClassDTO]?
    let interestedCenter: [CenterDTO]?
    let top10Class: [ClassDTO]?
    let top10Center: [CenterDTO]?
    let newReview: [YogaReviewDTO]
    /// API에서는 내려오지 않음. layoutOrder에만 yogaCategory 노출 여부가 내려오고, 모듈 데이터는 하드코딩 사용.
    let yogaCategory: [CategoryDTO]?
    let layoutOrder: [LayoutDTO]
}

struct TodayClassDTO: Codable {
    let classId: String
    let className: String
    let type: ClassType
    let address: String
    let scheduleId: String
    let startTime: String
    let endTime: String
}

struct MainBannerClassDTO: Codable {
    let classId: String
    let className: String
    let description: String?
    let thumbnail: String
}

struct ClassDTO: Codable, Equatable {
    let classId: String
    let className: String
    let thumbnail: String
    let masterId: String?
    let masterName: String?
    let rating: Double?
    let review: Int?
    let categories: [String]?
}

struct CenterDTO: Codable, Equatable {
    let centerId: String
    let address: String
    let name: String
    let thumbnail: String?
    let favoriteCount: Int
    let isFavorite: Bool
}

struct YogaReviewDTO: Codable {
    let reviewId: String
    let userUuid: String
    let thumbnail: String
    let content: String
    let rating: Double
    let createdAt: String
}

struct CategoryDTO: Codable, Hashable {
    let categoryId: String
    let name: String
}

struct LayoutDTO: Codable {
    let order: String
    let type: String
    let key: String
    let text: String?
}

// MARK: - Yoga Category 하드코딩 데이터 (layoutOrder에만 노출 제어, 모듈 데이터는 전부 하드코딩)
enum YogaCategoryHardcoded {
    /// 취향탐색(하루수련)용 카테고리
    static let oneDay: [CategoryDTO] = [
        CategoryDTO(categoryId: "1", name: "릴렉스"),
        CategoryDTO(categoryId: "2", name: "파워"),
        CategoryDTO(categoryId: "3", name: "초심자"),
        CategoryDTO(categoryId: "4", name: "이색요가"),
        CategoryDTO(categoryId: "5", name: "전통 요가")
    ]
    /// 위치탐색(정규수련)용 카테고리
    static let regular: [CategoryDTO] = [
        CategoryDTO(categoryId: "1", name: "서울"),
        CategoryDTO(categoryId: "2", name: "경기도"),
        CategoryDTO(categoryId: "3", name: "경상도"),
        CategoryDTO(categoryId: "4", name: "강원도"),
        CategoryDTO(categoryId: "5", name: "전라도"),
        CategoryDTO(categoryId: "6", name: "충청도"),
        CategoryDTO(categoryId: "7", name: "제주도"),
        CategoryDTO(categoryId: "8", name: "기타")
    ]
    
    static func items(for classType: ClassType) -> [CategoryDTO] {
        switch classType {
        case .oneDay: return oneDay
        case .regular: return regular
        }
    }
}

// MARK: - Category Class Response
// TODO: 추후 여러 Response가 추가되면 제네릭 APIResponse<T>로 리팩토링 고려
struct CategoryClassResponse: Codable {
    let code: Int
    let status: String
    let data: [CategoryClassDTO]
}

// MARK: - Home Section
enum HomeSection: Identifiable {
    case todayClass(title: String, items: [TodayClassDTO])
    case imageBanner(title: String, items: [MainBannerClassDTO])
    case interestedClass(title: String, items: [ClassDTO])
    case interestedCenter(title: String, items: [CenterDTO])
    case top10Class(title: String, items: [ClassDTO])
    case top10Center(title: String, items: [CenterDTO])
    case newReview(title: String, items: [YogaReviewDTO])
    case yogaCategory(title: String, items: [CategoryDTO])
    
    var id: String {
        switch self {
        case .todayClass: return "todayClass"
        case .imageBanner: return "imageBanner"
        case .interestedClass: return "interestedClass"
        case .interestedCenter: return "interestedCenter"
        case .top10Class: return "top10Class"
        case .top10Center: return "top10Center"
        case .newReview: return "newReview"
        case .yogaCategory: return "yogaCategory"
        }
    }
    
    var title: String {
        switch self {
        case .todayClass(let title, _),
             .imageBanner(let title, _),
             .interestedClass(let title, _),
             .interestedCenter(let title, _),
             .top10Class(let title, _),
             .top10Center(let title, _),
             .newReview(let title, _),
             .yogaCategory(let title, _):
            return title
        }
    }
    
    /// API key로 HomeSection 생성. layoutOrder에 포함된 키만 섹션으로 생성하며, yogaCategory는 데이터 없이 하드코딩으로 노출.
    static func create(
        fromKey key: String,
        title: String,
        data: MainDataDTO,
        classType: ClassType
    ) -> HomeSection? {
        switch key {
        case "todayClass":
            return .todayClass(title: title, items: data.todayClass)
        case "imageBanner":
            guard !data.imageBanner.isEmpty else { return nil }
            return .imageBanner(title: title, items: data.imageBanner)
        case "interestedClass":
            guard let items = data.interestedClass, !items.isEmpty else { return nil }
            return .interestedClass(title: title, items: items)
        case "interestedCenter":
            guard let items = data.interestedCenter, !items.isEmpty else { return nil }
            return .interestedCenter(title: title, items: items)
        case "yogaCategory":
            // layoutOrder에 포함되면 노출. 모듈 데이터는 하드코딩 사용
            return .yogaCategory(title: title, items: YogaCategoryHardcoded.items(for: classType))
        case "top10Class":
            guard let items = data.top10Class, !items.isEmpty else { return nil }
            return .top10Class(title: title, items: items)
        case "top10Center":
            guard let items = data.top10Center, !items.isEmpty else { return nil }
            return .top10Center(title: title, items: items)
        case "newReview":
            guard !data.newReview.isEmpty else { return nil }
            return .newReview(title: title, items: data.newReview)
        default:
            return nil
        }
    }
}

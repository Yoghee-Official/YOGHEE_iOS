//
//  CategoryMainContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/18/25.
//

import SwiftUI
import Foundation

// MARK: - Intent
enum CategoryMainIntent {
    case initialize(categoryId: String, classType: ClassType)
    case selectCategory(categoryId: String)
    case applyFilter(FilterOption)
    case selectClass(String)
    case toggleFavorite(classId: String)
    case toggleFilterSheet
}

// MARK: - State
struct CategoryMainState: Equatable {
    var classes: [CategoryClassDTO] = []
    var selectedFilter: FilterOption = .recommended
    var selectedCategoryId: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var showFilterSheet: Bool = false
}

// MARK: - Filter Option
enum FilterOption: String, CaseIterable {
    case recommended = "추천순"
    case favorites = "찜순"
    case reviews = "리뷰순"
    case priceHigh = "높은 금액 순"
    case priceLow = "낮은 금액 순"
    case yogheeClubOnly = "요기클럽 전용"

    var apiValue: String? {
        switch self {
        case .recommended: return "recommend"
        case .favorites: return "favorite"
        case .reviews: return "review"
        case .priceHigh: return "expensive"
        case .priceLow: return "cheap"
        case .yogheeClubOnly: return nil
        }
    }
}

// MARK: - Container
@MainActor
class CategoryMainContainer: ObservableObject {
    @Published private(set) var state = CategoryMainState()
    private var classType: ClassType = .regular
    
    func handleIntent(_ intent: CategoryMainIntent) {
        switch intent {
        case .initialize(let categoryId, let type):
            classType = type
            state.selectedCategoryId = categoryId
            loadClasses(categoryId: categoryId, sort: state.selectedFilter.apiValue)

        case .selectCategory(let categoryId):
            state.selectedCategoryId = categoryId
            loadClasses(categoryId: categoryId, sort: state.selectedFilter.apiValue)

        case .applyFilter(let filter):
            state.selectedFilter = filter
            loadClasses(categoryId: state.selectedCategoryId, sort: filter.apiValue)
            
        case .selectClass(let classId):
            print("클래스로 이동")
            // TODO: 추후 클래스 상세 화면으로 네비게이션
            
        case .toggleFavorite(let classId):
            // 불변 업데이트: map으로 새 배열 생성
            state.classes = state.classes.map { item in
                var updated = item
                if updated.classId == classId {
                    updated.isFavorite.toggle()
                    print("찜하기 토글: \(classId), 현재 상태: \(updated.isFavorite)")
                }
                return updated
            }
            // TODO: 추후 API 호출로 찜하기 상태 동기화
            
        case .toggleFilterSheet:
            state.showFilterSheet.toggle()
        }
    }
    
    private func loadClasses(categoryId: String, sort: String?) {
        state.isLoading = true
        state.errorMessage = nil

        Task {
            do {
                let classes: [CategoryClassDTO]
                switch classType {
                case .regular:
                    classes = try await APIService.shared.getAddressClasses(regionCode: categoryId, sort: sort)
                case .oneDay:
                    classes = try await APIService.shared.getCategoryClasses(categoryCode: categoryId, sort: sort)
                }
                self.state.classes = classes
                self.state.isLoading = false
                print("✅ 카테고리 클래스 로드 완료: \(classes.count)개")
            } catch {
                self.state.errorMessage = error.localizedDescription
                self.state.isLoading = false
                print("❌ 카테고리 클래스 로드 실패: \(error)")
            }
        }
    }
}

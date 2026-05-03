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
    case initialize(categoryId: String, type: String)
    case selectCategory(categoryId: String, type: String)
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
}

// MARK: - Container
@MainActor
class CategoryMainContainer: ObservableObject {
    @Published private(set) var state = CategoryMainState()
    
    func handleIntent(_ intent: CategoryMainIntent) {
        switch intent {
        case .initialize(let categoryId, let type):
            state.selectedCategoryId = categoryId
            loadClasses(categoryId: categoryId, type: type)
            
        case .selectCategory(let categoryId, let type):
            state.selectedCategoryId = categoryId
            print("\(categoryId) 카테고리 선택")
            loadClasses(categoryId: categoryId, type: type)
            
        case .applyFilter(let filter):
            state.selectedFilter = filter
            print("\(filter.rawValue) 필터 적용")
            // TODO: 추후 필터링 로직 구현 or API 재호출
            
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
    
    private func loadClasses(categoryId: String, type: String) {
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.getCategoryClasses(
                    categoryId: categoryId,
                    type: type
                )
                
                self.state.classes = response.data
                self.state.isLoading = false
                print("✅ 카테고리 클래스 로드 완료: \(response.data.count)개")
                
            } catch {
                self.state.errorMessage = error.localizedDescription
                self.state.isLoading = false
                print("❌ 카테고리 클래스 로드 실패: \(error)")
            }
        }
    }
}

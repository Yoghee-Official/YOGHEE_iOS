//
//  HomeTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/13/25.
//

import SwiftUI
import Foundation

// MARK: - Intent
enum HomeIntent {
    case loadMainData
    /// 당겨서 새로고침 - 기존 화면을 유지한 채 다시 불러옴
    case refresh
    case selectItem(String, String) // itemId, sectionId
    case toggleClassType(ClassType)
    case clearNavigation
}

// MARK: - State
struct HomeState: Equatable {
    var sections: [HomeSection] = []
    var selectedClassType: ClassType = .oneDay
    var isLoading: Bool = false
    /// 당겨서 새로고침 진행 중 (전체 화면 로딩 없이 기존 섹션 유지)
    var isRefreshing: Bool = false
    /// 메인 데이터 로드 실패 시 노출할 연결 오류 화면 (ER_MO_1/2)
    var connectionError: ConnectionErrorKind?
    var navigationDestination: NavigationDestination?
    
    static func == (lhs: HomeState, rhs: HomeState) -> Bool {
        return lhs.selectedClassType == rhs.selectedClassType &&
               lhs.isLoading == rhs.isLoading &&
               lhs.isRefreshing == rhs.isRefreshing &&
               lhs.connectionError == rhs.connectionError &&
               lhs.sections.count == rhs.sections.count &&
               lhs.navigationDestination == rhs.navigationDestination
    }
}

// MARK: - Navigation Destination
enum NavigationDestination: Hashable {
    case notifications
    case classDetail(String)
    case reviewDetail(String)
    case categoryDetail(categoryId: String, categoryName: String, categoryType: ClassType, categories: [CategoryDTO])
}

@MainActor
class HomeTabContainer: ObservableObject {
    @Published private(set) var state = HomeState()
    
    init() {
        loadMainData()
    }
    
    func handleIntent(_ intent: HomeIntent) {
        switch intent {
        case .loadMainData:
            loadMainData()
        case .refresh:
            guard !state.isLoading, !state.isRefreshing else { return }
            loadMainData(isRefresh: true)
        case .selectItem(let itemId, let sectionId):
            print("Selected item: \(itemId) from section: \(sectionId)")
            handleItemSelection(itemId: itemId, sectionId: sectionId)
        case .toggleClassType(let type):
            state.selectedClassType = type
            loadMainData()
        case .clearNavigation:
            state.navigationDestination = nil
        }
    }
    
    private func handleItemSelection(itemId: String, sectionId: String) {
        // sectionId에 따라 적절한 네비게이션 처리
        switch sectionId {
        case "yogaCategory":
            // yogaCategory 섹션에서 카테고리 정보 찾기
            if let section = state.sections.first(where: { $0.id == "yogaCategory" }),
               case .yogaCategory(_, let items) = section,
               let category = items.first(where: { $0.categoryId == itemId }) {
                state.navigationDestination = .categoryDetail(
                    categoryId: itemId,
                    categoryName: category.name,
                    categoryType: state.selectedClassType,
                    categories: items
                )
            }
        case "todayClass", "imageBanner", "interestedClass", "top10Class",
             "interestedCenter", "top10Center":
            state.navigationDestination = .classDetail(itemId)
        case "newReview":
            state.navigationDestination = .reviewDetail(itemId)
        default:
            print("Unknown section: \(sectionId)")
        }
    }
    
    private func loadMainData(isRefresh: Bool = false) {
        if isRefresh {
            state.isRefreshing = true
        } else {
            state.isLoading = true
        }
        
        Task { @MainActor in
            do {
                // APIService를 사용하여 메인 데이터 조회
                let response = try await APIService.shared.getMainData(
                    type: state.selectedClassType.rawValue
                )
                
                await MainActor.run {
                    self.state.sections = self.createSections(from: response.data, classType: self.state.selectedClassType)
                    self.state.connectionError = nil
                    self.state.isLoading = false
                    self.state.isRefreshing = false
                }
                
            } catch {
                // 디코딩 오류도 APIService에서 APIError.decodingError로 감싸져 이곳으로 온다
                print("❌ 홈 메인 데이터 로딩 실패: \(error)")

                await MainActor.run {
                    // 새로고침 실패 시 기존 섹션이 있으면 그대로 유지하고, 없을 때만 오류 화면 노출
                    if !isRefresh || self.state.sections.isEmpty {
                        self.state.connectionError = error.connectionErrorKind
                    }
                    self.state.isLoading = false
                    self.state.isRefreshing = false
                }
            }
        }
    }
    
    private func createSections(from data: MainDataDTO, classType: ClassType) -> [HomeSection] {
        var sections: [HomeSection] = []
        
        // layoutOrder에 따라 섹션 생성 (yogaCategory는 layoutOrder에 포함되면 하드코딩 데이터로 노출)
        for layoutType in data.layoutOrder {
            let title = layoutType.text ?? ""
            
            if let section = HomeSection.create(fromKey: layoutType.key, title: title, data: data, classType: classType) {
                sections.append(section)
            }
        }
        
        return sections
    }
}

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
    case selectItem(String, String) // itemId, sectionId
    case toggleTrainingMode(TrainingMode)
    case clearNavigation
}

// MARK: - Training Mode
enum TrainingMode: CaseIterable, Equatable {
    case oneDay
    case regular
    
    var title: String {
        switch self {
        case .oneDay: return "하루수련"
        case .regular: return "정규수련"
        }
    }
    
    var apiType: String {
        switch self {
        case .oneDay: return "O"
        case .regular: return "R"
        }
    }
}

// MARK: - State
struct HomeState: Equatable {
    var sections: [HomeSection] = []
    var selectedTrainingMode: TrainingMode = .regular
    var isLoading: Bool = false
    var errorMessage: String?
    var navigationDestination: NavigationDestination?
    
    static func == (lhs: HomeState, rhs: HomeState) -> Bool {
        return lhs.selectedTrainingMode == rhs.selectedTrainingMode &&
               lhs.isLoading == rhs.isLoading &&
               lhs.errorMessage == rhs.errorMessage &&
               lhs.sections.count == rhs.sections.count &&
               lhs.navigationDestination == rhs.navigationDestination
    }
}

// MARK: - Navigation Destination
enum NavigationDestination: Hashable {
    case notifications
    case classDetail(String)
    case reviewDetail(String)
    case categoryDetail(categoryId: String, categoryName: String, categoryType: String)
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
        case .selectItem(let itemId, let sectionId):
            print("Selected item: \(itemId) from section: \(sectionId)")
            handleItemSelection(itemId: itemId, sectionId: sectionId)
        case .toggleTrainingMode(let mode):
            state.selectedTrainingMode = mode
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
                    categoryType: category.type
                )
            }
        case "todayClass", "imageBanner", "interestedClass", "top10Class":
            state.navigationDestination = .classDetail(itemId)
        case "newReview":
            state.navigationDestination = .reviewDetail(itemId)
        default:
            print("Unknown section: \(sectionId)")
        }
    }
    
    private func loadMainData() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task { @MainActor in
            do {
                let url = URL(string: "https://www.yoghee.xyz/api/main/?type=\(state.selectedTrainingMode.apiType)")!
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // 🔍 디버깅: Raw JSON 출력
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 API Response JSON:")
                    print(jsonString)
                }
                
                let response = try JSONDecoder().decode(MainResponse.self, from: data)
                
                await MainActor.run {
                    self.state.sections = self.createSections(from: response.data)
                    self.state.isLoading = false
                }
                
            } catch let decodingError as DecodingError {
                // 🔍 디코딩 에러 상세 로깅
                await MainActor.run {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("❌ 디코딩 에러: 키 '\(key.stringValue)' 없음")
                        print("   경로: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                        print("   설명: \(context.debugDescription)")
                        self.state.errorMessage = "데이터 구조 오류: \(key.stringValue) 필드 누락"
                        
                    case .typeMismatch(let type, let context):
                        print("❌ 디코딩 에러: 타입 불일치 (예상: \(type))")
                        print("   경로: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                        print("   설명: \(context.debugDescription)")
                        self.state.errorMessage = "데이터 타입 오류"
                        
                    case .valueNotFound(let type, let context):
                        print("❌ 디코딩 에러: 값 없음 (예상 타입: \(type))")
                        print("   경로: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                        print("   설명: \(context.debugDescription)")
                        self.state.errorMessage = "데이터 값 누락"
                        
                    case .dataCorrupted(let context):
                        print("❌ 디코딩 에러: 데이터 손상")
                        print("   경로: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                        print("   설명: \(context.debugDescription)")
                        self.state.errorMessage = "데이터 손상"
                        
                    @unknown default:
                        print("❌ 알 수 없는 디코딩 에러: \(decodingError)")
                        self.state.errorMessage = "알 수 없는 디코딩 에러"
                    }
                    
                    self.state.isLoading = false
                }
                
            } catch {
                // 🔍 기타 에러 로깅
                print("❌ 네트워크/기타 에러: \(error)")
                print("   상세: \(error.localizedDescription)")
                
                await MainActor.run {
                    self.state.errorMessage = "데이터 로딩 실패: \(error.localizedDescription)"
                    self.state.isLoading = false
                }
            }
        }
    }
    
    private func createSections(from data: MainDataDTO) -> [HomeSection] {
        var sections: [HomeSection] = []
        
        // layoutOrder에 따라 섹션 생성
        for layoutType in data.layoutOrder {
            let title = layoutType.text ?? ""
            
            if let section = HomeSection.create(fromKey: layoutType.key, title: title, data: data) {
                sections.append(section)
            }
        }
        
        return sections
    }
}

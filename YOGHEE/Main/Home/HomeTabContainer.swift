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
    case selectItem(String, LayoutSectionType)
    case toggleTrainingMode(TrainingMode)
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
    
    static func == (lhs: HomeState, rhs: HomeState) -> Bool {
        return lhs.selectedTrainingMode == rhs.selectedTrainingMode &&
               lhs.isLoading == rhs.isLoading &&
               lhs.errorMessage == rhs.errorMessage &&
               lhs.sections.count == rhs.sections.count
    }
}

// MARK: - Navigation Destination
enum NavigationDestination: Hashable {
    case notifications
    case classDetail(String)
    case reviewDetail(String)
    case categoryDetail(String)
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
        case .selectItem(let itemId, let sectionType):
            print("Selected item: \(itemId) from section: \(sectionType)")
            // TODO: 실제 네비게이션 구현
        case .toggleTrainingMode(let mode):
            state.selectedTrainingMode = mode
            loadMainData()
        }
    }
    
    private func loadMainData() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task { @MainActor in
            do {
                let url = URL(string: "https://www.yoghee.xyz/api/main/?type=\(state.selectedTrainingMode.apiType)")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(MainResponse.self, from: data)
                
                await MainActor.run {
                    self.state.sections = self.createSections(from: response.data)
                    self.state.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.state.errorMessage = "데이터 로딩 실패: \(error.localizedDescription)"
                    self.state.isLoading = false
                }
            }
        }
    }
    
    private func createSections(from data: MainData) -> [HomeSection] {
        var sections: [HomeSection] = []
        
        // layoutOrder에 따라 섹션 생성 - 추천 랭킹과 맞춤 수업 모듈 활성화
        for layoutType in data.layoutOrder {
            guard let sectionType = LayoutSectionType(rawValue: layoutType) else { continue }
            
            switch sectionType {
            case .recommendClass:
                if !data.recommendClass.isEmpty {
                    sections.append(HomeSection(type: .recommendClass, items: data.recommendClass))
                }
            case .customizedClass:
                if !data.customizedClass.isEmpty {
                    sections.append(HomeSection(type: .customizedClass, items: data.customizedClass))
                }
//            case .todayClass:
//                if !data.todayClass.isEmpty {
//                    sections.append(HomeSection(type: .todayClass, items: data.todayClass))
//                }
//            case .category:
//                if !data.yogaCategory.isEmpty {
//                    sections.append(HomeSection(type: .category, items: data.yogaCategory))
//                }
//            case .hotClass:
//                if !data.hotClass.isEmpty {
//                    sections.append(HomeSection(type: .hotClass, items: data.hotClass))
//                }
            case .newReview:
                if !data.newReview.isEmpty {
                    sections.append(HomeSection(type: .newReview, items: data.newReview))
                }
            default: break
            }
        }
        
        return sections
    }
}

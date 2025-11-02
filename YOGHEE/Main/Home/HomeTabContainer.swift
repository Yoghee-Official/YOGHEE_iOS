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
    
    private func createSections(from data: MainData) -> [HomeSection] {
        var sections: [HomeSection] = []
        
        // layoutOrder에 따라 섹션 생성
        for layoutType in data.layoutOrder {
            guard let sectionType = LayoutSectionType(rawValue: layoutType.key) else { continue }
            
            let customTitle = layoutType.text
            
            switch sectionType {
            case .todayClass:
                // todayClass는 빈 배열이어도 섹션 추가 (빈 상태 메시지 표시)
                sections.append(HomeSection(type: .todayClass, title: customTitle, items: data.todayClass))
                
            case .recommendClass:
                if !data.imageBanner.isEmpty {
                    sections.append(HomeSection(type: .recommendClass, title: customTitle, items: data.imageBanner))
                }
                
            case .interestedClass:
                if let items = data.interestedClass, !items.isEmpty {
                    sections.append(HomeSection(type: .interestedClass, title: customTitle, items: items))
                }
                
            case .interestedCenter:
                if let items = data.interestedCenter, !items.isEmpty {
                    sections.append(HomeSection(type: .interestedCenter, title: customTitle, items: items))
                }
                
            case .yogaCategory:
                if !data.yogaCategory.isEmpty {
                    sections.append(HomeSection(type: .yogaCategory, title: customTitle, items: data.yogaCategory))
                }
                
            case .top10Class:
                if let items = data.top10Class, !items.isEmpty {
                    sections.append(HomeSection(type: .top10Class, title: customTitle, items: items))
                }
                
            case .top10Center:
                if let items = data.top10Center, !items.isEmpty {
                    sections.append(HomeSection(type: .top10Center, title: customTitle, items: items))
                }
                
            case .newReview:
                if !data.newReview.isEmpty {
                    sections.append(HomeSection(type: .newReview, title: customTitle, items: data.newReview))
                }
            }
        }
        
        return sections
    }
}

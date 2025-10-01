//
//  HomeTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/13/25.
//

import SwiftUI

// MARK: - Intent
enum HomeIntent {
    case selectModule(Int)
    case toggleTrainingMode(TrainingMode)
}

// MARK: - Training Mode
enum TrainingMode: CaseIterable, Equatable {
    case daily
    case regular
    
    var title: String {
        switch self {
        case .daily: return "하루수련"
        case .regular: return "정규수련"
        }
    }
}

// MARK: - State
struct HomeState: Equatable {
    var modules: [HomeModule] = []
    var selectedTrainingMode: TrainingMode = .daily
}

// MARK: - Module Model
struct HomeModule: Identifiable, Equatable {
    let id: Int
    let color: Color
    let title: String
}

@MainActor
class HomeTabContainer: ObservableObject {
    @Published private(set) var state = HomeState()
    
    init() {
        state.modules = getModules(for: .daily)
    }
    
    func handleIntent(_ intent: HomeIntent) {
        switch intent {
        case .selectModule(let index):
            print("Selected module index: \(index)")
            // TODO: 실제 네비게이션 구현
        case .toggleTrainingMode(let mode):
            state.selectedTrainingMode = mode
            state.modules = getModules(for: mode)
        }
    }
    
    private func getModules(for mode: TrainingMode) -> [HomeModule] {
        switch mode {
        case .daily:
            return Self.dailyModules
        case .regular:
            return Self.regularModules
        }
    }
    
    // MARK: - Module Data
    private static let dailyModules: [HomeModule] = [
        HomeModule(id: 0, color: .red, title: "빨간 모듈"),
        HomeModule(id: 1, color: .orange, title: "주황 모듈"),
        HomeModule(id: 2, color: .yellow, title: "노란 모듈"),
        HomeModule(id: 3, color: .green, title: "초록 모듈"),
        HomeModule(id: 4, color: .blue, title: "파란 모듈"),
        HomeModule(id: 5, color: .indigo, title: "남색 모듈"),
        HomeModule(id: 6, color: .purple, title: "보라 모듈")
    ]
    
    private static let regularModules: [HomeModule] = [
        HomeModule(id: 10, color: .purple, title: "정규 보라 모듈"),
        HomeModule(id: 11, color: .indigo, title: "정규 남색 모듈"),
        HomeModule(id: 12, color: .blue, title: "정규 파란 모듈"),
        HomeModule(id: 13, color: .green, title: "정규 초록 모듈"),
        HomeModule(id: 14, color: .yellow, title: "정규 노란 모듈"),
        HomeModule(id: 15, color: .orange, title: "정규 주황 모듈"),
        HomeModule(id: 16, color: .red, title: "정규 빨간 모듈")
    ]
}

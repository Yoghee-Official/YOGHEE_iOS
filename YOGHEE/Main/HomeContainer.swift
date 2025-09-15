//
//  HomeContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/13/25.
//

import SwiftUI

// MARK: - Intent
enum HomeIntent {
    case selectModule(Int)
}

// MARK: - State
struct HomeState {
    var modules: [HomeModule] = []
}

// MARK: - Module Model
struct HomeModule: Identifiable {
    let id: Int
    let color: Color
    let title: String
}

@MainActor
class HomeContainer: ObservableObject {
    @Published private(set) var state = HomeState()
    
    init() {
        loadModules()
    }
    
    func handleIntent(_ intent: HomeIntent) {
        switch intent {
        case .selectModule(let index):
            print("Selected module: \(index)")
            // TODO: 실제 네비게이션 구현
        }
    }
    
    private func loadModules() {
        state.modules = [
            HomeModule(id: 0, color: .red, title: "빨간 모듈"),
            HomeModule(id: 1, color: .orange, title: "주황 모듈"),
            HomeModule(id: 2, color: .yellow, title: "노란 모듈"),
            HomeModule(id: 3, color: .green, title: "초록 모듈"),
            HomeModule(id: 4, color: .blue, title: "파란 모듈"),
            HomeModule(id: 5, color: .indigo, title: "남색 모듈"),
            HomeModule(id: 6, color: .purple, title: "보라 모듈")
        ]
    }
}
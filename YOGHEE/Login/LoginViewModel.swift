//
//  LoginViewModel.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI
import Combine

// MARK: - Intent
enum LoginIntent {
    case kakaoLogin
}

// MARK: - State
struct LoginState {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isLoggedIn: Bool = false
}

// MARK: - Effect
enum LoginEffect {
    case navigateToHome
    case showError(String)
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published private(set) var state = LoginState()
    private var cancellables = Set<AnyCancellable>()
    
    func handleIntent(_ intent: LoginIntent) {
        switch intent {
        case .kakaoLogin:
            performKakaoLogin()
        }
    }
    
    private func performKakaoLogin() {
        state.isLoading = true
        state.errorMessage = nil
        
        // 카카오 로그인 시뮬레이션 (실제 구현 시에는 카카오 SDK 사용)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.state.isLoading = false
            
            // 성공 시뮬레이션 (실제로는 카카오 로그인 결과에 따라 처리)
            let isSuccess = Bool.random()
            
            if isSuccess {
                self.state.isLoggedIn = true
                self.handleEffect(.navigateToHome)
            } else {
                self.state.errorMessage = "카카오 로그인에 실패했습니다. 다시 시도해주세요."
                self.handleEffect(.showError("로그인 실패"))
            }
        }
    }
    
    private func handleEffect(_ effect: LoginEffect) {
        switch effect {
        case .navigateToHome:
            // 네비게이션 처리는 View에서 담당
            break
        case .showError(let message):
            print("Error: \(message)")
        }
    }
}

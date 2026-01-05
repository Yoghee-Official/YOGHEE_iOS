//
//  LoginContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI
import Combine
import KakaoSDKUser
import KakaoSDKAuth

// MARK: - Intent
enum LoginIntent {
    case kakaoLogin
    case normalLogin
    case updateId(String)
    case updatePassword(String)
    case clearError
}

// MARK: - State
struct LoginState {
    var id: String = ""
    var password: String = ""
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var hasLoginError: Bool = false
    
    var isLoginButtonEnabled: Bool {
        return !id.isEmpty && !password.isEmpty && !hasLoginError && !isLoading
    }
}

// MARK: - Effect
// TODO: Effect 기능은 추후 구현 예정
/*
enum LoginEffect {
    case navigateToHome
    case showError(String)
}
*/

@MainActor
class LoginContainer: ObservableObject {
    @Published private(set) var state = LoginState()
    // TODO: Effect 기능은 추후 구현 예정
    // @Published var effect: LoginEffect? = nil
    
    func handleIntent(_ intent: LoginIntent) {
        switch intent {
        case .kakaoLogin:
            performKakaoLogin()
        case .normalLogin:
            performNormalLogin(id: state.id, password: state.password)
        case .updateId(let id):
            state.id = id
            if state.hasLoginError {
                state.hasLoginError = false
                state.errorMessage = nil
            }
        case .updatePassword(let password):
            state.password = password
            if state.hasLoginError {
                state.hasLoginError = false
                state.errorMessage = nil
            }
        case .clearError:
            state.hasLoginError = false
            state.errorMessage = nil
        }
    }
    
    // TODO: Effect 기능은 추후 구현 예정
    /*
    func clearEffect() {
        effect = nil
    }
    
    private func sendEffect(_ newEffect: LoginEffect) {
        effect = newEffect
    }
    */
    
    private func performKakaoLogin() {
        state.isLoading = true
        state.errorMessage = nil
        
        // 카카오톡 앱으로 인가코드 받기 시도
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                DispatchQueue.main.async {
                    self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
                }
            }
        } else {
            // 카카오톡 앱이 없으면 웹으로 인가코드 받기
            UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
                DispatchQueue.main.async {
                    self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
                }
            }
        }
    }
    
    private func handleKakaoLoginResult(oauthToken: OAuthToken?, error: Error?) {
        state.isLoading = false
        
        if let error = error {
            state.errorMessage = "로그인 실패: \(error.localizedDescription)"
            print("카카오 로그인 에러: \(error)")
            return
        }
        
        guard let oauthToken = oauthToken else {
            state.errorMessage = "로그인 토큰을 받지 못했습니다."
            return
        }
        
        print("카카오 로그인 성공!")
        print("Authorization Code: \(oauthToken.accessToken)")
        
        // 인가코드를 서버에 전송
        AuthManager.shared.handleSSOLogin(token: oauthToken.accessToken, ssoType: .kakao)
    }
    
    private func performNormalLogin(id: String, password: String) {
        state.isLoading = true
        state.errorMessage = nil
        state.hasLoginError = false
        
        // 임시로 로그인 실패를 시뮬레이션
        // TODO: 실제 API 호출로 대체
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.state.isLoading = false
            // 임시로 항상 실패하도록 설정 (테스트용)
            self?.state.hasLoginError = true
            self?.state.errorMessage = "* 아이디/비밀번호가 맞지않습니다."
        }
    }
}

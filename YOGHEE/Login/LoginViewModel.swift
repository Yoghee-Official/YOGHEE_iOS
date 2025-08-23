//
//  LoginViewModel.swift
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
}

// MARK: - State
struct LoginState {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isLoggedIn: Bool = false
    var userInfo: KakaoSDKUser.User? = nil
}

// MARK: - Effect
enum LoginEffect {
    case navigateToHome
    case showError(String)
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published private(set) var state = LoginState()
    
    func handleIntent(_ intent: LoginIntent) {
        switch intent {
        case .kakaoLogin:
            performKakaoLogin()
        }
    }
    
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
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
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
        AuthViewModel.shared.handleSSOLogin(token: oauthToken.accessToken, ssoType: .kakao)
        
        // 사용자 정보 가져오기 -> 테스트 코드 주석
        // fetchUserInfo()
    }
    
    private func fetchUserInfo() {
        UserApi.shared.me { [weak self] user, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.state.errorMessage = "사용자 정보 조회 실패: \(error.localizedDescription)"
                    print("사용자 정보 조회 에러: \(error)")
                    return
                }
                
                if let user = user {
                    self?.state.userInfo = user
                    self?.state.isLoggedIn = true
                    print("사용자 정보: \(user.kakaoAccount?.profile?.nickname ?? "알 수 없음")")
                    self?.handleEffect(.navigateToHome)
                }
            }
        }
    }
    
    private func handleEffect(_ effect: LoginEffect) {
        switch effect {
        case .navigateToHome:
            // 네비게이션 처리는 View에서 담당
            break
        case .showError(let message):
            state.errorMessage = message
            print("Error: \(message)")
        }
    }
}

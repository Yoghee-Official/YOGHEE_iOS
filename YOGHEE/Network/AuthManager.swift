//
//  AuthManager.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI
import Combine

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    private var isProcessingLogin = false // 중복 호출 방지
    
    // MARK: - Token Storage (단일 소스)
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessTokenKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: accessTokenKey)
            isAuthenticated = newValue != nil
        }
    }
    
    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: refreshTokenKey) }
    }
    
    private init() {
        // 앱 시작 시 저장된 토큰 확인
        checkSavedToken()
    }
    
    /// SSO 로그인 처리
    /// - Parameters:
    ///   - token: SSO 인가코드
    ///   - ssoType: SSO 타입
    func handleSSOLogin(token: String, ssoType: SSOType) {
        // 중복 호출 방지
        guard !isProcessingLogin else {
            print("⚠️ 이미 로그인 처리 중입니다.")
            return
        }
        
        print("🔐 SSO 로그인 시작")
        print("Code: \(token)")
        print("SSO Type: \(ssoType)")
        
        isProcessingLogin = true
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                print("📞 API 호출 중...")
                let response = try await APIService.shared.ssoLogin(token: token, ssoType: ssoType)
                
                print("📥 API 응답 받음")
                print("SSOLoginResponse: \(response)")
                
                if let loginData = response.data {
                    print("✅ 토큰 저장 중...")
                    // accessToken과 refreshToken 저장
                    self.accessToken = loginData.accessToken
                    self.refreshToken = loginData.refreshToken
                    print("✅ 로그인 성공!")
                    print("Access Token: \(loginData.accessToken)")
                    print("Refresh Token: \(loginData.refreshToken)")
                } else {
                    print("❌ 토큰이 nil입니다")
                    errorMessage = "로그인에 실패했습니다."
                }
            } catch {
                print("❌ 에러 발생: \(error)")
                errorMessage = error.localizedDescription
            }
            isLoading = false
            isProcessingLogin = false // 처리 완료
            print("🏁 SSO 로그인 완료")
        }
    }
    
    func checkAutoLogin() async {
        // 저장된 토큰이 없으면 종료
        guard let accessToken = accessToken,
              let refreshToken = refreshToken else {
            print("ℹ️ 저장된 토큰이 없습니다.")
            return
        }
        
        // 이미 처리 중이면 중복 호출 방지
        guard !isProcessingLogin else {
            print("⚠️ 이미 로그인 처리 중입니다.")
            return
        }
        
        isProcessingLogin = true
        isLoading = true
        errorMessage = nil
        
        print("🔄 자동 로그인 체크 시작")
        
        do {
            print("📞 토큰 갱신 API 호출 중...")
            let response = try await APIService.shared.refreshLoginToken(
                accessToken: accessToken,
                refreshToken: refreshToken
            )
            
            print("📥 토큰 갱신 응답 받음")
            print("SSOLoginResponse: \(response)")
            
            if let loginData = response.data {
                print("✅ 토큰 갱신 성공")
                // 새로운 토큰 저장
                self.accessToken = loginData.accessToken
                self.refreshToken = loginData.refreshToken
                print("✅ 자동 로그인 성공!")
                print("New Access Token: \(loginData.accessToken)")
                print("New Refresh Token: \(loginData.refreshToken)")
            } else {
                print("❌ 토큰 갱신 실패: 응답 데이터가 nil입니다")
                // 토큰 갱신 실패 시 로그아웃 처리
                logout()
                errorMessage = "자동 로그인에 실패했습니다."
            }
        } catch {
            print("❌ 토큰 갱신 에러 발생: \(error)")
            // 토큰 갱신 실패 시 로그아웃 처리
            logout()
            errorMessage = "자동 로그인에 실패했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
        isProcessingLogin = false
        print("🏁 자동 로그인 체크 완료")
    }
    
    /// 로그아웃
    func logout() {
        accessToken = nil
        refreshToken = nil
        isProcessingLogin = false
    }
    
    /// 저장된 토큰 확인
    func checkSavedToken() {
        isAuthenticated = accessToken != nil
    }
}

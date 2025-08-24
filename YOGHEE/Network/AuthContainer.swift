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
    @Published var authToken: String?
    private var isProcessingLogin = false // 중복 호출 방지
    
    private init() {
        // 앱 시작 시 저장된 토큰 확인
        checkSavedToken()
    }
    
    /// 인증 상태 확인 (토큰 존재 여부로 판단)
    var isAuthenticated: Bool {
        return authToken != nil
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
                
                if let jwtToken = response.data {
                    print("✅ 토큰 저장 중...")
                    authToken = jwtToken
                    // 토큰을 UserDefaults에 저장
                    UserDefaults.standard.set(jwtToken, forKey: "authToken")
                    print("✅ 로그인 성공!")
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
    
    /// 로그아웃
    func logout() {
        authToken = nil
        isProcessingLogin = false
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    /// 저장된 토큰 확인
    func checkSavedToken() {
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            authToken = token
        }
    }
}

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
    private var isProcessingLogin = false // SSO 로그인 중복 호출 방지

    // MARK: - Token Refresh (single-flight)
    /// 진행 중인 토큰 갱신 작업. 여러 곳에서 동시에 401을 맞아도
    /// 실제 갱신 API는 1번만 호출되고, 나머지는 이 작업의 결과를 기다린다.
    private var refreshTask: Task<Bool, Never>?
    
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
        guard accessToken != nil, refreshToken != nil else {
            print("ℹ️ 저장된 토큰이 없습니다.")
            return
        }

        print("🔄 자동 로그인 체크 시작")
        isLoading = true
        errorMessage = nil

        let success = await ensureValidToken()

        if success {
            print("✅ 자동 로그인 성공!")
        } else {
            print("❌ 자동 로그인 실패")
            errorMessage = "자동 로그인에 실패했습니다."
        }

        isLoading = false
        print("🏁 자동 로그인 체크 완료")
    }

    /// 토큰 갱신을 보장한다.
    /// - 이미 진행 중인 갱신 작업이 있으면 새로 호출하지 않고 그 결과를 기다린다(single-flight).
    ///   → 여러 API 호출이 동시에 401을 받아도 `/auth/refresh`는 1번만 호출된다.
    /// - 갱신에 성공하면 accessToken/refreshToken을 갱신하고 true를 반환한다.
    /// - 갱신에 실패하면(리프레시 토큰 만료 등) 로그아웃 처리 후 false를 반환한다.
    @discardableResult
    func ensureValidToken() async -> Bool {
        if let refreshTask {
            print("⏳ 이미 진행 중인 토큰 갱신을 대기합니다.")
            return await refreshTask.value
        }

        guard let currentAccessToken = accessToken,
              let currentRefreshToken = refreshToken else {
            return false
        }

        let task = Task<Bool, Never> { [weak self] in
            guard let self else { return false }
            do {
                print("📞 토큰 갱신 API 호출 중...")
                let response = try await APIService.shared.refreshLoginToken(
                    accessToken: currentAccessToken,
                    refreshToken: currentRefreshToken
                )

                guard let loginData = response.data else {
                    print("❌ 토큰 갱신 실패: 응답 데이터가 nil입니다")
                    self.logout()
                    return false
                }

                print("✅ 토큰 갱신 성공")
                self.accessToken = loginData.accessToken
                self.refreshToken = loginData.refreshToken
                return true
            } catch {
                print("❌ 토큰 갱신 에러 발생: \(error)")
                self.logout()
                return false
            }
        }

        refreshTask = task
        let result = await task.value
        refreshTask = nil
        return result
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

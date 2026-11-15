//
//  AuthManager.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI
import Combine
import Alamofire

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
    private var refreshTask: Task<TokenRefreshResult, Never>?
    
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

        switch await ensureValidToken() {
        case .refreshed:
            print("✅ 자동 로그인 성공!")
        case .rejected:
            print("❌ 자동 로그인 실패")
            errorMessage = "자동 로그인에 실패했습니다."
        case .failed:
            print("⚠️ 자동 로그인 일시 실패 - 서버/네트워크 오류")
            errorMessage = "일시적인 오류로 로그인을 확인하지 못했어요. 잠시 후 다시 시도해 주세요."
        }

        isLoading = false
        print("🏁 자동 로그인 체크 완료")
    }

    /// 토큰 갱신 결과
    enum TokenRefreshResult {
        /// 갱신 성공 - 새 토큰이 저장됨
        case refreshed
        /// 서버가 리프레시 토큰을 거절함(만료/무효) - 로그아웃 처리됨
        case rejected
        /// 5xx·타임아웃·네트워크 오류 등 일시적 실패 - 토큰은 그대로 유지됨
        case failed(Error)
    }

    /// 토큰 갱신을 보장한다.
    /// - 이미 진행 중인 갱신 작업이 있으면 새로 호출하지 않고 그 결과를 기다린다(single-flight).
    ///   → 여러 API 호출이 동시에 401을 받아도 `/auth/refresh`는 1번만 호출된다.
    /// - 갱신에 성공하면 accessToken/refreshToken을 갱신하고 `.refreshed`를 반환한다.
    /// - 서버가 리프레시 토큰을 거절하면(4xx) 로그아웃 처리 후 `.rejected`를 반환한다.
    /// - 5xx·네트워크 오류처럼 일시적인 실패는 토큰을 지우지 않고 `.failed`를 반환한다.
    ///   → 서버가 잠깐 불안정했다는 이유로 유효한 리프레시 토큰까지 잃지 않도록 한다.
    @discardableResult
    func ensureValidToken() async -> TokenRefreshResult {
        if let refreshTask {
            print("⏳ 이미 진행 중인 토큰 갱신을 대기합니다.")
            return await refreshTask.value
        }

        guard let currentAccessToken = accessToken,
              let currentRefreshToken = refreshToken else {
            return .rejected
        }

        let task = Task<TokenRefreshResult, Never> { [weak self] in
            guard let self else { return .rejected }
            do {
                print("📞 토큰 갱신 API 호출 중...")
                let response = try await APIService.shared.refreshLoginToken(
                    accessToken: currentAccessToken,
                    refreshToken: currentRefreshToken
                )

                guard let loginData = response.data else {
                    print("❌ 토큰 갱신 실패: 응답 데이터가 nil입니다")
                    self.logout()
                    return .rejected
                }

                print("✅ 토큰 갱신 성공")
                self.accessToken = loginData.accessToken
                self.refreshToken = loginData.refreshToken
                return .refreshed
            } catch {
                print("❌ 토큰 갱신 에러 발생: \(error)")
                if Self.isRefreshTokenRejected(error) {
                    print("🚪 리프레시 토큰이 거절됨 - 로그아웃합니다")
                    self.logout()
                    return .rejected
                }
                print("⚠️ 일시적인 갱신 실패 - 토큰을 유지합니다")
                return .failed(error)
            }
        }

        refreshTask = task
        let result = await task.value
        refreshTask = nil
        return result
    }

    /// 갱신 에러가 "리프레시 토큰 자체가 거절된 것"인지 판단한다.
    /// - 401/403 등 4xx: 토큰이 만료·무효 → true (로그아웃 대상)
    /// - 408(타임아웃)/429(요청 과다)는 4xx지만 일시적인 실패로 본다 → false
    /// - 5xx, 상태 코드 없는 네트워크 오류, 디코딩 오류 등 → false (토큰 유지)
    private static func isRefreshTokenRejected(_ error: Error) -> Bool {
        let statusCode: Int?
        switch error {
        case APIError.tokenExpired, APIError.unauthorized:
            return true
        case APIError.serverError(let code, _, _):
            statusCode = code
        case APIError.networkError(let underlying):
            statusCode = (underlying as? AFError)?.responseCode
        default:
            statusCode = nil
        }

        guard let statusCode, (400..<500).contains(statusCode) else { return false }
        return statusCode != 408 && statusCode != 429
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

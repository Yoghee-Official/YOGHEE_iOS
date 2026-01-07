//
//  MyPageTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Intent
enum MyPageTabIntent {
    case checkLoginStatus
    case login(userId: String, password: String)
    case logout
    case loadMyPageData
    
    // UserProfileModule 액션
    case editProfile
    case openSettings
    case openNotifications
    case viewLevelInfo
    case viewCategoryAnalysis
    
    // DetailContents 액션
    case selectDetailItem(String)
}

// MARK: - State
struct MyPageTabState: Equatable {
    var myPageData: MyPageDataDTO?
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedDetailItem: String?
    var isLoggedIn: Bool = false
    var showLoginSheet: Bool = false
    var showProfileEditSheet: Bool = false
}

@MainActor
class MyPageTabContainer: ObservableObject {
    @Published private(set) var state = MyPageTabState()
    @Published var showProfileEditSheet: Bool = false  // Sheet 표시용 (public)
    @Published var showLoginSheet: Bool = false  // LoginView Sheet 표시용 (public)
    
    init() {
        // init에서는 로그인 체크하지 않음
        // onAppear에서 체크하도록 변경
    }
    
    func handleIntent(_ intent: MyPageTabIntent) {
        switch intent {
        case .checkLoginStatus:
            checkLoginStatus()
        case .login(let userId, let password):
            // MARK: 계정 로그인 없애고 ssoLogin만 사용하는걸로 수정됨
//            login(userId: userId, password: password)
            break
        case .logout:
            logout()
        case .loadMyPageData:
            loadMyPageData()
            
        // UserProfileModule 액션
        case .editProfile:
            log("프로필 편집 클릭")
            showProfileEditSheet = true
            
        case .openSettings:
            log("앱 설정 클릭")
            // TODO: 설정 화면 이동 또는 로그아웃
            // logout()
            
        case .openNotifications:
            log("알림 클릭")
            // TODO: 알림 화면 이동
            
        case .viewLevelInfo:
            log("레벨 정보 클릭")
            // TODO: 레벨 상세 화면 이동
            
        case .viewCategoryAnalysis:
            log("카테고리 분석 클릭")
            // TODO: 카테고리 분석 화면 이동
            
        // DetailContents 액션
        case .selectDetailItem(let itemName):
            state.selectedDetailItem = itemName
            log("세부항목 '\(itemName)' 클릭")
            // TODO: 각 항목별 네비게이션 처리
            // - "설정" → 세부 설정 페이지
            // - "계정관리" → 계정관리 페이지
            // - "이용약관" → 이용약관 페이지
            // - "고객센터" → 고객센터 페이지
            // - "환불정책" → 환불정책 페이지
        }
    }
    
    // MARK: - Login Management
    
    /// 로그인 상태 확인
    private func checkLoginStatus() {
        let hasToken = AuthManager.shared.isAuthenticated
        state.isLoggedIn = hasToken
        
        if hasToken {
            // 토큰 있으면 데이터 로딩
            loadMyPageData()
            showLoginSheet = false
        } else {
            // 토큰 없으면 로그인 화면 표시
            showLoginSheet = true
        }
    }
    
    /// 로그인 처리
    // MARK: 계정 로그인 없애고 ssoLogin만 사용하는걸로 수정됨
//    private func login(userId: String, password: String) {
//        state.isLoading = true
//        state.errorMessage = nil
//        
//        Task { @MainActor in
//            do {
//                _ = try await APIService.shared.login(userId: userId, password: password)
//                log("✅ 로그인 성공")
//                
//                await MainActor.run {
//                    self.state.isLoggedIn = true
//                    self.state.showLoginSheet = false
//                    self.loadMyPageData()
//                }
//            } catch {
//                await MainActor.run {
//                    self.handleError(error, context: "로그인")
//                }
//            }
//        }
//    }
    
    /// 로그인 완료 후 호출
    func onLoginSuccess() {
        showLoginSheet = false
        state.isLoggedIn = true
        loadMyPageData()
    }
    
    /// 로그아웃
    private func logout() {
        AuthManager.shared.logout()
        state.isLoggedIn = false
        state.myPageData = nil
        showLoginSheet = true
    }
    
    /// TODO: 임시 - 자동 로그인 (나중에 제거)
    // MARK: 계정 로그인 없애고 ssoLogin만 사용하는걸로 수정됨
//    private func autoLoginAndLoadData() {
//        state.isLoading = true
//        state.errorMessage = nil
//        
//        Task { @MainActor in
//            do {
//                // 저장된 토큰이 없으면 자동 로그인
//                if !AuthManager.shared.isAuthenticated {
//                    // TODO: userId와 password를 하드코딩으로 입력
//                    let userId = ""  // ← 여기에 userId 입력
//                    let password = ""  // ← 여기에 password 입력
//                    
//                    _ = try await APIService.shared.login(userId: userId, password: password)
//                    log("✅ 자동 로그인 성공")
//                    self.state.isLoggedIn = true
//                }
//                
//                // 마이페이지 데이터 로딩
//                let response = try await APIService.shared.getMyPageData()
//                await MainActor.run {
//                    self.state.myPageData = response.data
//                    self.state.isLoading = false
//                }
//            } catch {
//                await MainActor.run {
//                    self.handleError(error, context: "자동 로그인")
//                }
//            }
//        }
//    }
    
    private func loadMyPageData() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task { @MainActor in
            do {
                let response = try await APIService.shared.getMyPageData()
                await MainActor.run {
                    self.state.myPageData = response.data
                    self.state.isLoading = false
                }
            } catch {
                // 401 에러 (만료된 토큰)인 경우 자동 로그인 시도
                switch error {
                case APIError.unauthorized, APIError.tokenExpired:
                    log("🔄 토큰 만료 감지 - 자동 로그인 시도")
                    
                    // 토큰 갱신 시도
                    await AuthManager.shared.checkAutoLogin()
                    
                    // 갱신 성공 시 재시도
                    if AuthManager.shared.isAuthenticated {
                        log("✅ 토큰 갱신 성공 - 데이터 재요청")
                        do {
                            let response = try await APIService.shared.getMyPageData()
                            await MainActor.run {
                                self.state.myPageData = response.data
                                self.state.isLoading = false
                            }
                        } catch {
                            await MainActor.run {
                                self.handleError(error, context: "MyPage 데이터 로딩")
                            }
                        }
                    } else {
                        // 갱신 실패 시 로그인 화면 표시
                        log("❌ 토큰 갱신 실패 - 로그인 화면 표시")
                        await MainActor.run {
                            self.showLoginSheet = true
                            self.state.isLoading = false
                        }
                    }
                default:
                    // 다른 에러인 경우 일반 에러 처리
                    await MainActor.run {
                        self.handleError(error, context: "MyPage 데이터 로딩")
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
    
    private func errorMessage(from error: Error, context: String) -> String {
        if let apiError = error as? APIError {
            return "\(context) 실패: \(apiError.localizedDescription)"
        } else {
            return "\(context) 실패: \(error.localizedDescription)"
        }
    }
    
    private func handleError(_ error: Error, context: String) {
        log("❌ \(context) 에러: \(error)")
        state.errorMessage = errorMessage(from: error, context: context)
        state.isLoading = false
    }
}

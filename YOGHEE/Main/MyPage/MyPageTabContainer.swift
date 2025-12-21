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
}

@MainActor
class MyPageTabContainer: ObservableObject {
    @Published private(set) var state = MyPageTabState()
    
    init() {
        // TODO: 현재는 자동 로그인, 나중에는 checkLoginStatus()로 변경
        autoLoginAndLoadData()
    }
    
    func handleIntent(_ intent: MyPageTabIntent) {
        switch intent {
        case .checkLoginStatus:
            checkLoginStatus()
        case .login(let userId, let password):
            login(userId: userId, password: password)
        case .logout:
            logout()
        case .loadMyPageData:
            loadMyPageData()
            
        // UserProfileModule 액션
        case .editProfile:
            log("프로필 편집 클릭")
            // TODO: 프로필 편집 화면 이동
            
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
        let hasToken = APIService.shared.accessToken != nil
        state.isLoggedIn = hasToken
        
        if hasToken {
            // 토큰 있으면 데이터 로딩
            loadMyPageData()
        } else {
            // 토큰 없으면 로그인 화면 표시
            state.showLoginSheet = true
        }
    }
    
    /// 로그인 처리
    private func login(userId: String, password: String) {
        state.isLoading = true
        state.errorMessage = nil
        
        Task { @MainActor in
            do {
                _ = try await APIService.shared.login(userId: userId, password: password)
                log("✅ 로그인 성공")
                
                await MainActor.run {
                    self.state.isLoggedIn = true
                    self.state.showLoginSheet = false
                    self.loadMyPageData()
                }
            } catch {
                await MainActor.run {
                    self.handleError(error, context: "로그인")
                }
            }
        }
    }
    
    /// 로그아웃
    private func logout() {
        APIService.shared.accessToken = nil
        APIService.shared.refreshToken = nil
        state.isLoggedIn = false
        state.myPageData = nil
        state.showLoginSheet = true
    }
    
    /// TODO: 임시 - 자동 로그인 (나중에 제거)
    private func autoLoginAndLoadData() {
        state.isLoading = true
        state.errorMessage = nil
        
        Task { @MainActor in
            do {
                // 저장된 토큰이 없으면 자동 로그인
                if APIService.shared.accessToken == nil {
                    // TODO: userId와 password를 하드코딩으로 입력
                    let userId = ""  // ← 여기에 userId 입력
                    let password = ""  // ← 여기에 password 입력
                    
                    _ = try await APIService.shared.login(userId: userId, password: password)
                    log("✅ 자동 로그인 성공")
                    self.state.isLoggedIn = true
                }
                
                // 마이페이지 데이터 로딩
                let response = try await APIService.shared.getMyPageData()
                await MainActor.run {
                    self.state.myPageData = response.data
                    self.state.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.handleError(error, context: "자동 로그인")
                }
            }
        }
    }
    
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
                await MainActor.run {
                    self.handleError(error, context: "MyPage 데이터 로딩")
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

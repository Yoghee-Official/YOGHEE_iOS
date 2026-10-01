//
//  MyPageTabContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

// MARK: - Navigation Destination
enum MyPageNavigationDestination: Hashable {
    case settings
    case messageBox
    case classRegister
    /// 지도자 세부항목 "지도자 인증" 진입점
    case licenseRegister
}

// MARK: - Intent
enum MyPageTabIntent {
    case checkLoginStatus
//    case login(userId: String, password: String)
    case logout
    case loadMyPageData
    
    // UserProfileModule 액션
    case editProfile
    case openSettings
    case openNotifications
    case viewLevelInfo
    case viewCategoryAnalysis
    
    // ClassRegister 액션
    case openClassRegister
    
    // DetailContents 액션
    case selectDetailItem(String)
    
    // 아이템 선택 액션
    case selectItem(String, String) // itemId, sectionId
    
    // 토글 액션
    case switchRole(UserRole)  // 역할 전환
    
    // 네비게이션 액션
    case clearNavigation
}

// MARK: - State
struct MyPageTabState: Equatable {
    var sections: [MyPageSection] = []
    var myPageData: MyPageDataDTO?
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedDetailItem: String?
    var isLoggedIn: Bool = false
    var showLoginSheet: Bool = false
    var showProfileEditSheet: Bool = false
    var currentRole: UserRole = .yogini  // 기본값: 요기니
    var navigationDestination: MyPageNavigationDestination? = nil
    
    /// 현재 Role의 Configuration
    var sectionConfiguration: MyPageSectionConfiguration {
        return MyPageSectionConfiguration(role: currentRole)
    }
    
    static func == (lhs: MyPageTabState, rhs: MyPageTabState) -> Bool {
        return lhs.sections.count == rhs.sections.count &&
               lhs.isLoading == rhs.isLoading &&
               lhs.errorMessage == rhs.errorMessage &&
               lhs.isLoggedIn == rhs.isLoggedIn &&
               lhs.currentRole == rhs.currentRole &&
               lhs.navigationDestination == rhs.navigationDestination
    }
}

@MainActor
class MyPageTabContainer: ObservableObject {
    @Published private(set) var state = MyPageTabState()
    @Published var showProfileEditSheet: Bool = false  // Sheet 표시용 (public)
    @Published var showLoginSheet: Bool = false  // LoginView Sheet 표시용 (public)
    /// 지도자 토글 진입 시, 아직 지도자 인증(자격증 등록)을 받지 않은 사용자에게 노출하는 안내 팝업 (피그마 Alert_18)
    @Published var showLicensePrompt: Bool = false
    
    init() {
        // init에서는 로그인 체크하지 않음
        // onAppear에서 체크하도록 변경
    }
    
    func handleIntent(_ intent: MyPageTabIntent) {
        switch intent {
        case .checkLoginStatus:
            checkLoginStatus()
//        case .login(let userId, let password):
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
            state.navigationDestination = .settings
            
        case .openNotifications:
            log("알림 클릭")
            state.navigationDestination = .messageBox
            
        case .viewLevelInfo:
            log("레벨 정보 클릭")
            // TODO: 레벨 상세 화면 이동
            
        case .viewCategoryAnalysis:
            log("카테고리 분석 클릭")
            // TODO: 카테고리 분석 화면 이동
            
        // ClassRegister 액션
        case .openClassRegister:
            log("클래스 등록하기 클릭")
            state.navigationDestination = .classRegister
            
        // DetailContents 액션
        case .selectDetailItem(let itemName):
            state.selectedDetailItem = itemName
            log("세부항목 '\(itemName)' 클릭")
            switch itemName {
            case "지도자 인증":
                state.navigationDestination = .licenseRegister
            default:
                break
                // TODO: 각 항목별 네비게이션 처리
                // - "설정" → 세부 설정 페이지
                // - "계정관리" → 계정관리 페이지
                // - "이용약관" → 이용약관 페이지
                // - "고객센터" → 고객센터 페이지
                // - "환불정책" → 환불정책 페이지
            }
            
        // 아이템 선택 액션
        case .selectItem(let itemId, let sectionId):
            log("Selected item: \(itemId) from section: \(sectionId)")
            handleItemSelection(itemId: itemId, sectionId: sectionId)
            
        // 토글 액션
        case .switchRole(let role):
            let previousRole = state.currentRole
            state.currentRole = role
            log("역할 전환: \(previousRole.displayName) → \(role.displayName)")

            // 역할 변경 시 데이터 다시 불러오기
            // 요기니 → 지도자로 "새로 진입"할 때만 인증 여부를 확인한다 (이미 지도자 탭에 있는 상태에서의 새로고침 등은 제외)
            loadMyPageData(checkInstructorCertification: previousRole != .instructor && role == .instructor)
            
        // 네비게이션 액션
        case .clearNavigation:
            state.navigationDestination = nil
        }
    }
    
    private func handleItemSelection(itemId: String, sectionId: String) {
        // sectionId에 따라 적절한 네비게이션 처리
        switch sectionId {
        case "weekClasses", "todayClasses", "reservedClasses":
            // 클래스 상세 화면으로 이동
            log("클래스 상세 화면 이동: \(itemId)")
            // TODO: 네비게이션 처리
        case "favoriteOneDayClasses", "favoriteRegularClasses":
            // 찜한 클래스 상세 화면으로 이동
            log("찜한 클래스 상세 화면 이동: \(itemId)")
            // TODO: 네비게이션 처리
        default:
            log("Unknown section: \(sectionId)")
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
    
    /// - Parameter checkInstructorCertification: true면 로딩 완료 후 지도자 인증 여부(leaderProfile.certificate)를 확인해
    ///   미인증 상태일 경우 지도자 인증 안내 팝업(showLicensePrompt)을 띄운다. 지도자 토글에 "새로 진입"할 때만 true로 넘긴다.
    private func loadMyPageData(checkInstructorCertification: Bool = false) {
        state.isLoading = true
        state.errorMessage = nil

        Task { @MainActor in
            do {
                let response = try await APIService.shared.getMyPageData(for: state.currentRole)
                await MainActor.run {
                    self.state.myPageData = response.data
                    self.state.sections = self.createSections(from: response.data)
                    self.state.isLoading = false

                    if checkInstructorCertification {
                        let certificate = response.data.leaderProfile?.certificate
                        if certificate?.isEmpty ?? true {
                            log("⚠️ 지도자 인증 미완료 - 안내 팝업 노출")
                            self.showLicensePrompt = true
                        }
                    }
                }
            } catch {
                // 토큰 만료(401)에 대한 갱신+재시도는 APIService 내부에서 이미 처리되고 온 뒤이므로,
                // 여기서 401을 받았다는 것은 리프레시 토큰까지 만료되어 갱신이 실패했다는 뜻이다.
                // → 재시도하지 않고 바로 로그인 화면을 띄운다.
                switch error {
                case APIError.unauthorized, APIError.tokenExpired:
                    log("❌ 토큰 갱신 실패 - 로그인 화면 표시")
                    await MainActor.run {
                        self.showLoginSheet = true
                        self.state.isLoading = false
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
    
    private func createSections(from data: MyPageDataDTO) -> [MyPageSection] {
        let config = state.sectionConfiguration
        var sections: [MyPageSection] = []
        
        // availableSections 순서대로 섹션 생성
        for sectionType in config.availableSections {
            switch sectionType {
            case .profile:
                // 요기니와 지도자 모두 프로필 있으면 추가
                if data.userProfile != nil || data.leaderProfile != nil {
                    sections.append(.profile)
                }
                
            case .weekClasses:
                // 요기니 전용 - 이번주 수업
                sections.append(.weekClasses(weekDay: data.weekClasses?.weekDay,
                                             weekEnd: data.weekClasses?.weekEnd))
                
            case .todayClasses:
                // 지도자 전용 - 오늘의 수업
                sections.append(.todayClasses(items: data.todayClasses ?? []))
                
            case .reservedClasses:
                // 공통 (요기니: 예약한 수업, 지도자: 예약된 수업)
                if let reservedClasses = data.reservedClasses, !reservedClasses.isEmpty {
                    sections.append(.reservedClasses(items: reservedClasses))
                }
                
            case .favoriteClasses:
                // 요기니 전용 - 찜한 수련
                if let favoriteClasses = data.favoriteClasses, !favoriteClasses.isEmpty {
                    sections.append(.favoriteClasses(items: favoriteClasses))
                }
                
            case .favoriteCenters:
                // 요기니 전용 - 찜한 요가원
                if let favoriteCenters = data.favoriteCenters, !favoriteCenters.isEmpty {
                    sections.append(.favoriteCenters(items: favoriteCenters))
                }
                
            case .classRegisterBanner:
                // 지도자 전용 - 클래스 등록하기 배너
                sections.append(.classRegisterBanner)
                
            case .detailContents:
                sections.append(.detailContents)
            }
        }
        
        return sections
    }
    
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
